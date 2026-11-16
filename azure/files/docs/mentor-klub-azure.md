# Mentor Klub segédlet - Azure témájú képzésekhez

Képzésekre itt tudsz jelentkezni: https://gerillamentorklub.hu

Összes segédanyag: https://github.com/cloudsteak/mentor-klub-cloud

## Technikai nehézségek bejelentése és nyomonkövetése

Ha a képzések során valamilyen nehézségbe ütközöl, az alábbi github felületen tudsz új hibajegyet rögzíteni vagy a meglévőek állapotát ellenőrizni.

https://github.com/cloudsteak/mentor-klub-cloud/issues

## Hozzáférés igénylése Azure előfizetéshez

Több hetes képzések esetén lehetőség van az oktató Azure előfizetéséhez átmeneti jogosultságot igényelni. Ehhez a megadott linken meg kell adni az alábbi adatokat:

- Név
- Valós email cím
- Biztonsági szó, amit a képzés oldalán találtok

Link: https://mentor-access-manager.azurewebsites.net

**Fontos:**
- Előforul, hogy a jóváhagyó email a levélszemét mappában köt ki. Ezt ellenőrizd.
- A jóváhagyás elfogadására 24 órád van, ezért kérlek, rendszeresen ellenőrizd az email fiókod.
- Állíts be erős jelszót
- Több faktoros azonosítást is állíts be.
- Erőforrások létrehozásánál olyan nevet használj, amely esetén be tudom azonosítnai, hogy az hozzád tartozik.
- Ha nincs szükséged egy erőforrásra, akkor állítsd le vagy inkább töröld le.
- Csak annyi erőforrást használj, amennyire feltétlenül szükséged van.
- Néhány naponta ellenőrizni fogom az erőforrásokat és ha sok vagy felesleges erőforrások vannak, azokat le fogom törölni.

## Meglévő segádanyagok az Azure témájú képzésekhez

### 1. NodeJS14 alapú React demo

Create React App mintaprojekt React 18-cal. A `Procfile` a `web: npm start` folyamatot indítja, a repó leírása szerint AWS Elastic Beanstalk Node.js 14 környezetére. Helyben az `npm start` a fejlesztői szervert a 3000-es porton nyitja meg.

Link: https://github.com/cloudsteak/react-demo-n14

### 2. NodeJS16 alapú React demo

Ugyanaz a Create React App felépítés, Node.js 16 futtatókörnyezetre. Itt is `Procfile` adja a `web: npm start` indítást, Elastic Beanstalkhez. Helyben a szokásos `npm start` és `npm run build` parancsokkal lehet használni.

Link: https://github.com/cloudsteak/react-demo-n16

### 3. NodeJS alapú webalkalmazás Azure-hoz

Express és EJS alapú minta Azure App Service-hez. A repó Node.js 24.22.1 vagy újabb verziót kér, a 24-es LTS vonalon. ESLint-teszt van mellé téve, a folyamatos integráció Azure Pipeline-nal és GitHub Actionszel is le van írva.

Link: https://github.com/cloudsteak/trn-node-demo

### 4. NodeJS alapú webalkalmazás Azure-hoz (docker változat)

Ugyanaz az Express és EJS alkalmazás, Docker image-ként a `node:24.22.2-slim` alapról. A repóban Docker-alapok leírás, AKS-példa manifest, GitHub Actions image-build és Azure Pipeline is van. A konténer a 3000-as porton figyel.

Link: https://github.com/cloudsteak/trn-node-docker-demo

### 5. Példa repository Azure Pipeline alapú megoldásokhoz

Azure DevOps YAML-minta, GitHub-kapcsolattal. Az `azure-pipelines.yml` két stage-et futtat `ubuntu-latest` agenten: egy shell-feladatot és egy rövid Python szkriptet (`app/main.py`). A README végigveszi a Git alapokat, a GitHub personal access token létrehozását és a service connection beállítását.

Link: https://github.com/cloudsteak/trn-azure-pipeline

### 6. Parancssori eszközök Azure-hoz

Azure PowerShell (`Az` modul) és Azure CLI telepítése, bejelentkezés, előfizetés-kezelés és Cloud Shell. Külön jegyzetek szólnak virtuális gépről, VMSS-ről, virtuális hálózatról, VPN-ről, storage-ról és cloud-initről. A példaparancsok PowerShellben és Azure CLI-ben is szerepelnek.

Link: https://github.com/cloudsteak/trn-azure-commandline

### 7. Statikus weboldal

Egyszerű HTML minta (`index.html` és `error.html`) Azure Storage statikus webhelyéhez. Saját stílust és Font Awesome asseteket használ, build lépés nincs. A fájlokat a storage-fiók `$web` tárolójába kell feltölteni.

Link: https://github.com/cloudsteak/trn-azurestaticwebsite

### 8. WebApp + SQL adatbázis

Express és EJS alkalmazás, amely Azure SQL Database-hez csatlakozik az `mssql` csomaggal. A minta egy katalógust tart fenn (`Elem` és `ElemKategoria` táblák). A README végigviszi az adatbázis létrehozását, a séma feltöltését, majd a helyi és az App Service-es futtatást.

Link: https://github.com/cloudsteak/trn-azure-webapp-sql

### 9. webApp + NoSQL adatbázis

Express és EJS alkalmazás Azure Table Storage-hoz, az `@azure/data-tables` csomaggal. A kezdőoldal listázza az entitásokat, egy űrlap pedig új sort vesz fel. A kapcsolatot az `AZURE_STORAGE_CONNECTION_STRING`, az `AZURE_TABLE_NAME` és az `AZURE_TABLE_PARTITION_KEY` környezeti változók adják meg.

Link: https://github.com/cloudsteak/trn-azure-webapp-nosql

### 10. Kubernetes példa, több felhőszolgáltatóhoz

Node.js webalkalmazás konténerbe csomagolva, a `node:18.16.0` image-ről. Helyben a 80-as portra van kiadva, az AKS-példa az `aks/node-webapp.yaml` fájlban van, és Azure Pipeline építi az image-et. A kidolgozott telepítési példa az Azure Kubernetes Service.

Link: https://github.com/cloudsteak/trn-k8s

### 11. ARM sablonok Azure (ARM Template)

Egy Linux virtuális gép ARM-sablonja, hálózati interfésszel, hálózati biztonsági csoporttal és publikus IP-címmel. Az üzembe helyezés PowerShellből (`New-AzResourceGroupDeployment`) vagy Azure CLI-ből (`az deployment group create`) megy, előtte erőforráscsoporttal. A parancssori előkészítés a `trn-azure-commandline` repóra épül.

Link: https://github.com/cloudsteak/trn-azure-arm

### 12. Egyedi képfájl használata Azure-ban (Vírtuális gép)

Szkriptek és leírások egyedi gépfájlokhoz Azure-ra és AWS-re. Az Azure-os anyag a generalize lépést, az AWS-os az AMI készítését írja le. A `scripts` mappában minta systemd unitok és telepítési jegyzetek vannak egy teszt weboldalhoz és egy SQL szolgáltatáshoz.

Link: https://github.com/cloudsteak/cloud-custom-images
