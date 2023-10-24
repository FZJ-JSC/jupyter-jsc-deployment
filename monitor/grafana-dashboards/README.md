# Creating or editing dashboards

When adding new JupyterHub deployments, systems or nodes, you can use the `deploy.py` script in the [`create_grafana_dashboards` branch](https://gitlab.jsc.fz-juelich.de/jupyterjsc/k8s/fleet-deployment/-/tree/create_grafana_dashboards) instead of manually editing the configmaps.

You will need to run the script twice, once for staging and once for production. Once deployed, navigate to each dashboard's JSON model (Dashboard settings > JSON Model) and copy as the admin user. Paste the contents into the respective configmap file.