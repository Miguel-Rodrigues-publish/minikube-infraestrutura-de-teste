################################################################################
directoria_terraform  := iac/terraform/codigo_terraform
################################################################################

.PHONY : minikube
minikube:
	minikube status ||  minikube start --driver="virtualbox" ;\
	eval $$(minikube docker-env)

################################################################################
#
# cli
#
################################################################################
# variaveis Makefile
namespace_usar_1 := infraestutura-teste-ns-1
namespace_usar_2 := infraestutura-teste-ns-2
directoria_yaml  := "iac/k8s/yaml/"
################################################################################
# criacao dos namespaces necessários
################################################################################
cli_namespaces: minikube
	kubectl  create namespace $(namespace_usar_1) || echo "namespace $(namespace_usar_1) já existe " \;
	kubectl  create namespace $(namespace_usar_2) || echo "namespace $(namespace_usar_2) já existe "

################################################################################
# deployment pod
################################################################################
cli_faz_deployment1a:
	kubectl  apply -f $(directoria_yaml)/deployment1a.yaml --namespace=$(namespace_usar_1)
cli_rm_deployment1a:
	# *deployment1a* existe tambem dentro de deployment1a.yaml e não existem uma
	# forma *directa* de usarmos  uma variavel
	kubectl  delete deployment deployment1a --namespace=$(namespace_usar_1)
cli_faz_deployment1b:
	kubectl  apply -f $(directoria_yaml)/deployment1b.yaml --namespace=$(namespace_usar_2)
cli_rm_deployment1a:
	# *deployment1a* existe tambem dentro de deployment1b.yaml e não existem uma
	# forma *directa* de usarmos  uma variavel
	kubectl  delete deployment deployment1b --namespace=$(namespace_usar_2)
cli_faz_deployment: cli_faz_deployment1a cli_faz_deployment1b
cli_rm_deployment: cli_rm_deployment1a cli_rm_deployment1b

cli_teste_deployment1a:
	# *5001* existe tambem dentro de deployment1a.yaml e não existem uma
	# forma *directa* de usarmos  uma variavel
	PODS=`kubectl  get pods --namespace=$(namespace_usar_1) --output=json | jq '.items[]|.status|.podIP'` ;\
	PORT=5001;\
	for P in $$PODS ; do minikube  ssh curl $$P:$$PORT; done

cli_teste_deployment1b:
	# *5001* existe tambem dentro de deployment1b.yaml e não existem uma
	# forma *directa* de usarmos  uma variavel
	PODS=`kubectl  get pods --namespace=$(namespace_usar_2) --output=json | jq '.items[]|.status|.podIP'` ;\
	PORT=5001;\
	for P in $$PODS ; do minikube  ssh curl $$P:$$PORT; done

cli_teste_deployment: cli_teste_deployment1a cli_teste_deployment1b

################################################################################
#
# Terraform
#
################################################################################

inicializacao_terraform:
	test -d $(directoria_terraform)/.terraform ||  \
		 (cd $(directoria_terraform) ; terraform init)

################################################################################
# criacao dos namespaces necessários
################################################################################
terraform_cria_namespaces: minikube inicializacao_terraform
		 cd $(directoria_terraform) ;\
		 TF_VAR_dados_yaml=../dados_terraform/minikube.yaml terraform   apply  -auto-approve

terraform_limpa: minikube inicializacao_terraform
		 cd $(directoria_terraform) ;\
		 TF_VAR_dados_yaml=../dados_terraform/minikube.yaml terraform   destroy  -auto-approve
