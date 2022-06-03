# Why use certificates for JupyterHub internal communication

If we start a JupyterLab on a compute node on a HPC system, there's no internet available. So we have to communicate to JupyterHub via a remote tunnel, running on one of the login nodes. The remote tunnels are managed by the drf-tunnel webservice.  
The communication between compute node and login node is not encrypted. Therefore, anyone with root privilege on the hpc system may have a look at the communication between JupyterLab and JupyterHub.  

Same problem for the other way around. JupyterHub communicates to JupyterLab via login node, which forwards the traffic unencrypted to the compute node. So we start JupyterHub and each JupyterLab with a certificate. Using https the communication is encrypted.  

# Why we have to create certificates manually before
In Zero2JupyterHub proxy and JupyterHub are running in different pods. If both webservices using SSL, the other webservice need to know at least the used certificate authority.  

# JupyterHub needs to trust the (self signed) JupyterLab certificate
JupyterHub itself creates one certificate for each JupyterLab. Therefore, there is no additional work required here.

# JupyterLab needs to trust the (self signed) proxy-client certificate authority
When JuypterLab tries to communicate to JupyterHub, it uses the Remote Tunnel opened by DRF-Tunnel webservice. This ssh-tunnel forwards all traffic to the "proxy-public" K8s Service, which targets the proxy pod. Therefore, the proxy certificate must support the bind address used by the `ssh` tunneling command. To avoid updating all JupyterLabs when adding new LoginNodes or whole systems, the JupyterLab trusts the proxy-client-ca certificate. This has a lifetime of 5 years.   
  
Add `notebooks-ca_trust.crt` to your JupyterLab Jobs. Trusting this certificate will allow you to communicate with JupyterHub safely.  

# Adding new Login Nodes / Systems
As mentioned in the bullet point above, the proxy-client certificate must support all bind addresses. So we have to create a new proxy-client certificate and restart the proxy pod. It is important to reuse the ca certificates. They are stored in our Vault instance at "jupyterhub-ca_certs-dir". Use this secret value to create a ca_certs.tar.gz file, which includes all used ca certificates. An update for the JupyterLabs or JupyterHub is not necessary.

```
echo -n "<vault_secret_jupyterhub-ca_certs-dir>" | base64 -d > ca_certs.tar.gz
tar -xzf ca_certs.tar.gz
# Update jupyterhub_config.py - add DNS names to your liking
jupyterhub -f jupyterhub_config.py  # JupyterHub>2.1.1 must be installed
# Stop JupyterHub after "[...] JupyterHub is now running at http://:8000"
bash internal-ssh_to_secret.sh > secret.yaml
kubectl -n jupyterjsc apply -f secret.yaml
kubectl -n juypterjsc rollout restart proxy
```

# Create new Certificate Authorities
Only required every 5 years!
Requires a stop of all JupyterLabs and other JupyterHub-sub-services, because JupyterHub will not be trusted by the running JupyterLabs anymore.
```
# Update jupyterhub_config_create_new_cas.py - add DNS names to your liking
jupyterhub -f jupyterhub_config_create_new_cas.py
# Stop JupyterHub after "[...] JupyterHub is now running at http://:8000"
rm -rf new_ca_certs/certipy.json
rm -rf new_ca_certs/hub-internal
mkdir internal-ssl
mv new_ca_certs/proxy-api internal-ssl/proxy-api
mv new_ca_certs/proxy-client internal-ssl/proxy-client
mv new_ca_certs ca_certs
bash internal-ssh_to_secret.sh > secret.yaml
kubectl -n jupyterjsc apply -f secret.yaml
kubectl -n juypterjsc rollout restart proxy
```

You then have to restart everything JupyterHub related and update the proxy-client-ca.crt for all services. Remember to update service_descriptions in k8smgr and unicoremgr.

