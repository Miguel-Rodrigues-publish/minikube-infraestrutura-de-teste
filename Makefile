################################################################################
# Docker e minikube
#		Estes passos só estrão disponíveis se o minikube estiver instalado
################################################################################

.PHONY : minikube
minikube:
	minikube status ||  minikube start --driver="virtualbox" ;\
	eval $$(minikube docker-env)


#
# criacao dos namespaces necessários
#
namespace_usar_1 := infraestutura-teste-ns-1
namespace_usar_2 := infraestutura-teste-ns-2
namespaces: minikube
	kubectl  create namespace $(namespace_usar_1) || echo "namespace $(namespace_usar_1) já existe "
	kubectl  create namespace $(namespace_usar_2) || echo "namespace $(namespace_usar_2) já existe "
	echo "fim namespace"
