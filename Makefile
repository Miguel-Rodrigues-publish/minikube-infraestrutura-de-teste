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

################################################################################
# criacao dos namespaces necessários
################################################################################
namespace_usar_1 := infraestutura-teste-ns-1
namespace_usar_2 := infraestutura-teste-ns-2
cli_namespaces: minikube
	kubectl  create namespace $(namespace_usar_1) || echo "namespace $(namespace_usar_1) já existe " \;
	kubectl  create namespace $(namespace_usar_2) || echo "namespace $(namespace_usar_2) já existe "

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
		 pwd ;\
		 VARIAVEIS_YAML=../dados_terraform/minikube.yaml terraform plan
