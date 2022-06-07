c.JupyterHub.internal_ssl=True
c.JupyterHub.internal_certs_location = "new_ca_certs"
c.JupyterHub.trusted_alt_names = [
  "DNS:proxy-api",
  "DNS:hub",
  "DNS:drf-k8smgr-jupyterhub-forward.jupyterjsc.svc",
  "DNS:drf-k8smgr-jupyterhub-forward.userlabs.svc",
  "DNS:jrlogin01i",
  "DNS:jrlogin02i",
  "DNS:jrlogin03i",
  "DNS:jrlogin04i",
  "DNS:jrlogin05i",
  "DNS:jrlogin06i",
  "DNS:jrlogin07i",
  "DNS:jrlogin08i",
  "DNS:jrlogin09i",
  "DNS:jrlogin10i",
  "DNS:jrlogin11i",
  "DNS:jrlogin12i",
  "DNS:jrlogin13i",
  "DNS:jrlogin14i",
  "DNS:jwlogin00i",
  "DNS:jwlogin01i",
  "DNS:jwlogin02i",
  "DNS:jwlogin03i",
  "DNS:jwlogin04i",
  "DNS:jwlogin05i",
  "DNS:jwlogin06i",
  "DNS:jwlogin07i",
  "DNS:jwlogin08i",
  "DNS:jwlogin09i",
  "DNS:jwlogin10i",
  "DNS:jwlogin11i",
  "DNS:jwvis00i",
  "DNS:jwvis01i",
  "DNS:jwvis02i",
  "DNS:jwvis03i",
  "DNS:jwlogin21i",
  "DNS:jwlogin22i",
  "DNS:jwlogin23i",
  "DNS:jwlogin24i",
  "DNS:hdfmll01",
  "DNS:hdfmll02",
  "DNS:deepv",
  "DNS:jsfl01i",
  "DNS:jsfl02i",
  "DNS:jsfl03i",
  "DNS:jsfl04i",
]