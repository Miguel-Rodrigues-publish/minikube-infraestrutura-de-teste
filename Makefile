################################################################################
# Docker e minikube
#		Estes passos só estrão disponíveis se o minikube estiver instalado
################################################################################

.PHONY : minikube
minikube:
	minikube status ||  minikube start --driver="virtualbox" ;\
	eval $$(minikube docker-env)
