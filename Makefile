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
	kubectl  create namespace $(namespace_usar_1) || \
		echo "namespace $(namespace_usar_1) já existe " \;
	kubectl  create namespace $(namespace_usar_2) || \
		echo "namespace $(namespace_usar_2) já existe "

##############################################################################
# deployment como pods
cli_faz_deployment1a:
	kubectl  apply -f $(directoria_yaml)/deployment1a.yaml --namespace=$(namespace_usar_1)
cli_faz_deployment1b:
	kubectl  apply -f $(directoria_yaml)/deployment1b.yaml --namespace=$(namespace_usar_2)
cli_faz_deployment: cli_faz_deployment1a cli_faz_deployment1b
# teste deployment pod
cli_teste_deployment1a:
	# *5001* existe tambem dentro de deployment1a.yaml e não existem uma
	# forma *directa* de usarmos  uma variavel
	PODS=`kubectl  get pods --namespace=$(namespace_usar_1) --output=json | jq '.items[]|.status|.podIP'` ;\
	PORT=5001;\
	for P in $$PODS ; do minikube  ssh curl $$P:$$PORT; done
cli_teste_deployment1b:
	# *6000* existe tambem dentro de deployment1b.yaml e não existem uma
	# forma *directa* de usarmos  uma variavel
	PODS=`kubectl  get pods --namespace=$(namespace_usar_2) --output=json | jq '.items[]|.status|.podIP'` ;\
	PORT=6000;\
	for P in $$PODS ; do minikube  ssh curl $$P:$$PORT; done
cli_teste_deployment: cli_teste_deployment1a cli_teste_deployment1b
# limpeza deployment
cli_rm_deployment1a:
	# *deployment1a* existe tambem dentro de deployment1a.yaml e não existem uma
	# forma *directa* de usarmos  uma variavel
	kubectl  delete deployment deployment1a --namespace=$(namespace_usar_1)
cli_rm_deployment1b:
	# *deployment1a* existe tambem dentro de deployment1b.yaml e não existem uma
	# forma *directa* de usarmos  uma variavel
	kubectl  delete deployment deployment1b --namespace=$(namespace_usar_2)
cli_rm_deployment: cli_rm_deployment1a cli_rm_deployment1b

##############################################################################
# deployment como serviços
cli_faz_servico1a:
	# 5000 foi definido em deployment1a.yaml e aqui tambem
	# deployment1a foi definido em deployment1a.yaml e aqui tambem
	kubectl expose deployment deployment1a  --type=NodePort --port=5001 --namespace=$(namespace_usar_1)
cli_faz_servico1b:
	# 6000 foi definido em deployment1b.yaml e aqui tambem
	# deployment1b foi definido em deployment1a.yaml e aqui tambem
	kubectl expose deployment deployment1b  --type=NodePort --port=6000 --namespace=$(namespace_usar_2)
cli_faz_servico: cli_faz_servico1a cli_faz_servico1b
# teste deployment servicço
cli_teste_servico1a:
	# deployment1a foi definido em deployment1a.yaml e aqui tambem
	MINIKUBE_IP=`minikube ip` ;\
	PORT=`kubectl get service deployment1a --output='jsonpath="{.spec.ports[0].nodePort}"' --namespace=$(namespace_usar_1) | sed -e 's/"//g'`;\
	curl "http://$$MINIKUBE_IP:$$PORT"
cli_teste_servico1b:
	# deployment1b foi definido em deployment1a.yaml e aqui tambem
	MINIKUBE_IP=`minikube ip` ;\
	PORT=`kubectl get service deployment1b --output='jsonpath="{.spec.ports[0].nodePort}"' --namespace=$(namespace_usar_2) | sed -e 's/"//g'`;\
	curl "http://$$MINIKUBE_IP:$$PORT"
cli_teste_servico: cli_teste_servico1a cli_teste_servico1b
# limpeza servicos
cli_rm_servico1a:
	# deployment1a foi definido em deployment1a.yaml e aqui tambem
	kubectl  delete service deployment1a --namespace=$(namespace_usar_1)
cli_rm_servico1b:
	# deployment1b foi definido em deployment1b.yaml e aqui tambem
	kubectl  delete service deployment1b --namespace=$(namespace_usar_2)
cli_rm_servico: cli_rm_servico1a cli_rm_servico1b

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
