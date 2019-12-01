---
title: "建立一個單節點的 kubernetes cluster (kubeadm)"
date: 2019-07-29T17:18:19+08:00
draft: false
tags: ["kubernetes"]
---
## 前言
前一陣子開始使用 minikube 玩了一下 k8s，覺得有很多迷惑的地方，於是索性自己架設一個集群來幫助自己更了解 k8s cluster。

## Kubernetes Architecture
這是一個 kubernetes cluster 較完整的架構圖，本文的範疇只會在 Kubernetes Master 的綠色區塊。

![kubernetes architecture](https://fblog.ooopiz.com/images/2019/07/b001.png "kubernetes architecture")
(圖片來自WIKI)

## Master 節點的組件
- ETCD 集群
- API SERVER
- Controller Manager
- Scheduler

## 安裝準備 
先選定好要安裝在什麼 OS 上，  
並且選好 CNI 的方案，這邊用 Flannel，如不知道怎麼選，就先選跟文章一樣吧。  

下面列出我的環境跟CNI  

* OS（CoreOS）
    * 2 GB or more of RAM per machine (any less will leave little room for your apps)
    * 2 CPUs or more
* CNI（flannel）

## 安裝 kubeadm
* 官網文件：[Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
* 官網文件：[Creating a single control-plane cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

_我用的是 CoreOS 依照官網指示，如下安裝（官網如有更新，請依照官網）。_

### Install CNI plugins
```
CNI_VERSION="v0.7.5"
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz
```

### Install crictl
```
CRICTL_VERSION="v1.12.0"
mkdir -p /opt/bin
curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz
```

### Install kubeadm, kubelet, kubectl and add a kubelet systemd service:
```
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
mkdir -p /opt/bin
cd /opt/bin
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

### 啟動與開機自動啟動
`$ systemctl enable --now kubelet`

這個時候 kubelet 啟動尚未成功，是因為 kubeadm 還沒有 initialize。  
用 journalctl 看 log 的時候會有錯誤不用擔心。  

```
$ journalctl -f

# ============================================
Jul 25 06:37:02 localhost systemd[1]: kubelet.service: Service RestartSec=10s expired, scheduling restart.
Jul 25 06:37:02 localhost systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 69.
Jul 25 06:37:02 localhost systemd[1]: Stopped kubelet: The Kubernetes Node Agent.
Jul 25 06:37:02 localhost systemd[1]: Started kubelet: The Kubernetes Node Agent.
Jul 25 06:37:02 localhost kubelet[1462]: F0725 06:37:02.205296    1462 server.go:198] failed to load Kubelet config file /var/lib/kubelet/config.yaml, error failed to read kubelet config file "/var/lib/kubelet/config.yaml", error: open /var/lib/kubelet/config.yaml: no such file or directory
Jul 25 06:37:02 localhost systemd[1]: kubelet.service: Main process exited, code=exited, status=255/EXCEPTION
Jul 25 06:37:02 localhost systemd[1]: kubelet.service: Failed with result 'exit-code'.

```

## Install CNI（Flannel）
### kubeadm init
_--pod-network-cidr 必須跟後續的 cni yaml 腳本中的 cidr 互相配合_

```
$ sudo kubeadm init --pod-network-cidr=10.244.0.0/16


# ======================================================
[init] Using Kubernetes version: v1.15.1
[preflight] Running pre-flight checks
    [WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
    [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'


...


Your Kubernetes control-plane has initialized successfully!
To start using your cluster, you need to run the following as a regular user:
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/
Then you can join any number of worker nodes by running the following on each as root:
kubeadm join 10.0.2.15:6443 --token 86u3ts.46lvxxw10capjhr0 \
    --discovery-token-ca-cert-hash sha256:8fd26f90779603f91bbc0b89afd6dba3863f360f4a1eba23870957e6723d167c

```

_上面 ... 那邊會下載 image 回來，必須等待一下。_

![kubeadm init](https://fblog.ooopiz.com/images/2019/07/b002.jpg "kubeadm init")


完成後可以在 docker images 看到下載那些 image 回來。

![docker images](https://fblog.ooopiz.com/images/2019/07/b003.jpg "docker images")

## kubectl 設定檔
if not root user

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```

### 還沒安裝 cni 前
看一下 node 的狀態 status 為 NotReady
![kubernetes noready](https://fblog.ooopiz.com/images/2019/07/b004.jpg "kubernetes noready")

再看一下 pods 的狀態，有兩個 coredns 的 pods 尚未 ready

`$ kubectl get pods --all-namespaces`

`$ watch kubectl get pods --all-namespaces`

![pod noready](https://fblog.ooopiz.com/images/2019/07/b005.jpg "pod noready")

在後續安裝完 cni 都可以解決

## Install CNI（Flannel）
### 修改內核
```
$ vi /etc/sysctl.conf

# ================================
net.bridge.bridge-nf-call-iptables=1

```

`$ sysctl -p`

### 安裝 Flannel
`kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml`

### 安裝 cni 後
再看一下節點狀態，都是 ready 狀態了

![pod ready](https://fblog.ooopiz.com/images/2019/07/b006.jpg "pod ready")

## 移除控制節點的 Taints
預設集群不會將 pod 安排在控制節點。  
如果要建立一個單節點的集群必須執行如下的指令。  
`$ kubectl taint nodes --all node-role.kubernetes.io/master-`

![kubectl taint](https://fblog.ooopiz.com/images/2019/07/b007.jpg "kubectl taint")

## Test

`$ kubectl run my-nginx --image=nginx:alpine --port=80 --generator=run-pod/v1`

`$ kubectl expose pod my-nginx --type=NodePort --name=my-ng-srv --port=80 --target-port=80`

### 成功（存取的 port 記得使用你自己分配到的 port）
![kubernetes cluster](https://fblog.ooopiz.com/images/2019/07/b008.jpg "kubernetes cluster")
