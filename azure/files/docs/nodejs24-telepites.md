# NodeJS 24 telepítési útmutató

Ez az útmutató lépésről lépésre segít a NodeJS 24 verziójának telepítésében különböző operációs rendszerekre, mint Windows, Linux, és Mac.

## Tartalomjegyzék

1. [Bevezetés](#bevezetés)
2. [Windows](#windows)
    1. [Telepítés](#telepítés-windows)
3. [Linux](#linux)
    1. [Telepítés](#telepítés-linux)
4. [Mac](#mac)
    1. [Telepítés](#telepítés-mac)
5. [Ellenőrzés](#ellenőrzés)

## Bevezetés

A Node.js egy nyílt forráskódú, platformfüggetlen JavaScript futtatókörnyezet, amely lehetővé teszi a fejlesztők számára, hogy a szerveroldali és hálózati alkalmazásokat JavaScript-ben írhassák. Ehhez az útmutatóhoz a 24-es LTS vonal kell.

2026 októberében a Node.js projekt biztonsági kiadást adott ki. A 24-es ágon a javítás a **24.22.1**-es verzióban jelent meg, ezért ez a minimálisan biztonságos verzió: ennél régebbi 24.x kiadást ne használj. Telepítés után a `node --version` kimenete `v24.22.1` vagy újabb legyen.

Részletek: [Node.js security releases, 2026. október 21.](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases)

## Windows

### Telepítés (Windows)

1. Látogasson el a Node.js hivatalos weboldalára: [nodejs.org](https://nodejs.org)
2. A letöltéseknél a 24-es LTS vonalat válassza, **24.22.1** vagy újabb kiadással. A főoldali ajánlott gomb újabb főverziót is adhat, azt ennél az útmutatónál ne használja.
3. Töltse le a Windows Installer (.msi) fájlt, 32 vagy 64 bites verzióban, aszerint, hogy melyik illeszkedik a rendszeréhez.
4. Futtassa a letöltött telepítőt, és kövesse a telepítő utasításait. Az alapértelmezett beállítások többnyire megfelelőek, de ellenőrizze, hogy a "Add to PATH" opció be legyen jelölve, hogy a Node.js elérhető legyen a parancssorból.
5. A telepítés befejezése után újraindíthatja a számítógépet, bár ez általában nem szükséges.

## Linux

### Telepítés (Linux)

A Node.js telepítése Linuxon általában a rendszer csomagkezelőjén keresztül történik. Az alábbiakban a Debian és Ubuntu alapú disztribúciókhoz való telepítési lépéseket ismertetjük:

```bash
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Ez a parancssor letölti és futtatja a NodeSource Node.js 24.x telepítő scriptjét, majd telepíti a Node.js-t. A kész verzió legyen 24.22.1 vagy újabb.

## Mac

### Telepítés (Mac)

A Node.js telepítése Mac-re hasonló a Windows folyamatához:

1. Nyissa meg a [nodejs.org](https://nodejs.org) weboldalt a böngészőjében.
2. Töltse le a Mac-hez szánt 24-es LTS kiadást, **24.22.1** vagy újabbat. Ha a főoldal újabb főverziót kínál, ennél az útmutatónál maradjon a 24-es vonalon.
3. Nyissa meg a letöltött `.pkg` telepítő fájlt, ami elindítja a Node.js telepítőt.
4. Kövesse a telepítő lépéseit. A telepítő magában foglalja a Node.js-t és a npm-et (a Node.js csomagkezelőjét) is. Győződjön meg róla, hogy a telepítő beállítja a megfelelő útvonalakat.
5. A telepítés végén ellenőrizheti a telepítést a "Terminal" alkalmazásban.

## Ellenőrzés

A telepítés ellenőrzéséhez nyissa meg a parancssort vagy terminált, és írja be a következő parancsokat:

```bash
node --version
npm --version
```

Ezek a parancsok kiírják a telepített Node.js és npm (Node Package Manager) verzióit. A Node.js sora `v24.22.1` vagy annál újabb 24-es kiadás legyen. Ha mindkét parancs kiírja a verziószámot, a Node.js és az npm telepítve van.

Ezeken a lépéseken keresztül a Node.js 24-es vonalát telepítette a kívánt operációs rendszerre, a 2026. októberi javítást tartalmazó 24.22.1-es minimummal. Most már készen áll a Node.js használatára a fejlesztési projektekben, a szerveroldali scriptek írásától kezdve a teljes webalkalmazások fejlesztéséig.

Ha bármilyen problémába ütközik a telepítés során, javasoljuk, hogy keresse fel a Node.js [hivatalos dokumentációját](https://nodejs.org/en/docs/), ahol részletes útmutatásokat és a gyakori problémák megoldásait találja. Ezenkívül a Node.js közösség számos fórumon és csoporton keresztül nyújt támogatást, ahol segítséget kérhet és megoszthatja tapasztalatait más fejlesztőkkel.
