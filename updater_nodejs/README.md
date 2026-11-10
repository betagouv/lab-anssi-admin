# Updater NodeJS



## Get latest release

```
$ ./updater_nodejs --get-latest-release
22.23.4
24.22.2
26.13.0
27.0.0-alpha.0.0.0
```


## Analyze nvmrc

Fetch and update main branch and check if nodejs version in nvmrc is up-to-date

```
$ ./updater_nodejs --analyze-nvmrc /path/repositories/
filename                                               current          major      latest
anssi-mes-questions-cyber-journal/.nvmrc               24.14               24     24.22.2 	 ❌
anssi-demain-specialiste-cyber/.nvmrc                  26                  26     26.13.0 	 ❌
mon-service-securise-journal/.nvmrc                    24.14               24     24.22.2 	 ❌
lab-anssi-anti-typosquatting/.nvmrc                    24                  24     24.22.2 	 ❌
lab-anssi-ui-kit/.nvmrc                                26.13.0             26     26.13.0 	 ✅
mon-aide-cyber/.nvmrc                                  22.23.4             22     22.23.4 	 ✅
mon-profil-anssi/.nvmrc                                24                  24     24.22.2 	 ❌
anssi-portail/.nvmrc                                   26                  26     26.13.0 	 ❌
mon-aide-cyber-journal/.nvmrc                          24.14               24     24.22.2 	 ❌
mon-service-securise/.nvmrc                            24.22.2             24     24.22.2 	 ✅
anssi-lab-utilitaires/.nvmrc                           24                  24     24.22.2 	 ❌
lab-anssi-pala/.nvmrc                                  24.22.2             24     24.22.2 	 ✅
```

**analyze-nvmrc** updates its local repository. It could be long.
If your repositories are already updated, use `--no-update` to avoid theses updates.


## Create patch

Create patch in a specific branch, create staging and commit workflow (not push)

```
./updater_nodejs --create-patch /path/repositories/

```


## Analyze patch

Check if a patch has been implemented yet.

```
$ ./updater_nodejs --analyze-branch /path/repositories/

-----------------------------------------------------
anssi-mes-questions-cyber-journal                     
-----------------------------------------------------
main branch name : origin/main
fix branch name  : fix/node_bump
current version  : 24.14
latest version   : 24.22.2
-----------------------------------------------------
diff --git a/.nvmrc b/.nvmrc
index b74495a..fd655f8 100644
--- a/.nvmrc
+++ b/.nvmrc
@@ -1 +1 @@
-24.22.2
+24.14
-----------------------------------------------------
```


## Push patch

Push all patches from local to remote repository.
This process is **not** auto, you need to approve each push.


```
$ ./updater_nodejs --push /path/repositories/
```


## Pull Request

Create all pull request on github.
This process is **not** auto, you need to approve each creation.


```
$ ./updater_nodejs --pr /path/repositories/
```

