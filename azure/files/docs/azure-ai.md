# Alap AI példa Azure-ban

A mesterséges intelligencia továbbra is az egyik leggyakrabban kért téma a felhőben. 2026 októberére az Azure-os belépő már nem az Azure OpenAI Studio, hanem a Microsoft Foundry. Ez az útmutató azt a állapotot írja le: a portált, a modelleket, és azt, hogyan lehet a saját dokumentumainkra válaszoló csevegést összerakni.

## Azure AI 2026 októberében

A fejlesztői felület a [Microsoft Foundry](https://ai.azure.com/). A korábbi nevek (Azure OpenAI Studio, Azure AI Studio, Azure AI Foundry) ugyanerre a platformra vonatkoznak. A portál tetején a **New Foundry** kapcsolóval az új felületet használd. A modellhívás tokenenként számlázott, a portál megnyitása önmagában nem ingyenes.

Amit ezen a képzésen használunk:

- **Microsoft Foundry** a modellek telepítésére és a játszótérre. A háttérerőforrás típusa továbbra is `Microsoft.CognitiveServices/accounts`. A portálon ez Foundry-erőforrás és projekt. A régebbi, külön Azure OpenAI-fiók ugyanebbe a típusba tartozik, és átvihető Foundry-erőforrásra.
- **Foundry Tools** a kész AI-képességek. Ez a vonal volt korábban az Azure Cognitive Services, majd az Azure AI Services. Ide tartozik a Speech, a Translator, a Language, a Vision, a Document Intelligence, a Content Understanding és a Content Safety. A Decision és a Web Search kategória már nincs a kínálatban. Az Anomaly Detector, a Personalizer, a Content Moderator, a LUIS és a QnA Maker kivezetett szolgáltatás.
- **Azure AI Search**, a portálon Foundry IQ néven is. Ez adja a saját dokumentumok indexelését és a tudásbázist.
- **Azure Machine Learning** és **Azure Databricks** külön adat- és modellplatform. Új csevegőalkalmazást a Foundry Agent Service-ben érdemes kezdeni. Az Assistants API 2026. augusztus 26-án megszűnt.

A képzés két chat modellt telepít, mindkettő Global standard típusban:

- `gpt-5.4-mini`, verzió `2026-03-17`. Rövidebb, olcsóbb csevegéshez. A kontextusablak 400 000 token.
- `gpt-5.6-luna`, verzió `2026-07-09`. Nagyobb következtető modell, 1 050 000 tokenes ablakkal.

A katalógusban 2026 októberére a GPT-5.5, a GPT-5.6 (`sol`, `terra`, `luna`) és a GPT-6 vonal is elérhető. Ezen a képzésen a fenti két deploymenttel dolgozunk. Beágyazáshoz a `text-embedding-3-large` az aktuális javasolt modell. A `text-embedding-ada-002` még telepíthető, de egy meglévő index beágyazását nem lehet modellváltással átrakni: új vektorokat kell képezni.

## Hogyan kezdjük el?

Nyisd meg a [Microsoft Foundry](https://ai.azure.com/) portált, és kapcsold be a **New Foundry** nézetet. A modell csak akkor hívható, ha készült hozzá deployment. A deployment neve az, amit a kérés `model` mezőjében megadsz.

### Deployment létrehozása

1. A Foundry portálon menj a **Build > Catalog > Model Catalog** oldalra.
2. Válaszd a `gpt-5.4-mini` modellt. A nagyobb feladatokhoz ismételd meg a lépéseket a `gpt-5.6-luna` modellel.
3. **Deploy > Default settings**, ha az alapértelmezett név és a Global standard megfelel. Egyedi névhez a **Deploy > Custom settings** való.
4. Az Azure által árult modelleknél, így ezeknél a GPT-knél, nincs Marketplace-előfizetés. Partner modellnél (például Llama) a feltételeket el kell fogadni.
5. A sikeres deployment után a játszótér nyílik meg. A listát a **Build > Models** alatt látod. A státusz **Succeeded** legyen.

A projektnek és az erőforrásnak olyan régióban kell lennie, ahol a modell Global standard típusa elérhető.

### Chat játszótér

1. **Build > Models**, majd a deployment.
2. Írd be a kérdést a játszótérbe.
3. A **Code** fülön látszik az endpoint és a hívás mintája. A Responses API az aktuális felület. A Chat Completions API ezeknél a modelleknél még elérhető.

A rendszerpromptot, a temperature értéket és az eszközöket (webes keresés, fájlkeresés, kódinterpreter) ugyanitt lehet állítani. Ez a játszótér a modellt magát próbálja ki. A saját dokumentumok bekötése külön lépés, és 2026. október 14. óta már nem az „Add your data” gomb.

## Saját adatforrás

Az **Azure OpenAI On Your Data** 2026. október 14-én kivezetésre került. A Chat játszótérben az **Add your data**, a Blob-ból automatikusan indexelő varázsló és a `data_sources` mezős chat hívás erre a kivezetett rétegre mutatott. Új munkához ne ezt keresd.

A helyette használt réteg a **Foundry IQ**. Az adat az Azure AI Search indexében marad. Egy knowledge source mutat az indexre vagy közvetlenül a Blob-tárolóra, egy knowledge base pedig ehhez köti a chat modellt. A portálos varázsló a `2026-08-01-preview` API-t használja. A válaszösszeállítás (answer synthesis) és a lekérdezéstervezés ebben a felületben előnézet. Az éles, GA út a `2026-04-01` API, ami kivonatokat ad vissza, a mondatba szedett választ pedig az alkalmazás írja meg. A képzési gyakorlatban a portálos út elég.

A saját anyagon dolgozó válasz ettől még ugyanazt tudja, amit korábban vártunk tőle: a feltöltött dokumentumokból indul, és a találatokat hivatkozásként visszaadja. A hallucináció ettől nem tűnik el, csak szűkül az a halmaz, amiből a modell dolgozik.

A tudásbázis két helyen fogyaszt tokent: az Azure AI Search az agentic retrieval miatt, a chat modell a tervezés és a válasz miatt.

### 1. Foundry-erőforrás

1. Lépj be az [Azure Portalra](https://portal.azure.com/).
2. **Erőforrás létrehozása**.
3. Keress a **Microsoft Foundry** szolgáltatásra. Ha a találat még Azure OpenAI néven jön fel, az ugyanaz a `Microsoft.CognitiveServices/accounts` típus.
4. **Létrehozás**.
5. Töltsd ki a mezőket. Tarifacsomag: **Standard S0**. A projekt a Foundry-erőforrással együtt jön létre.
6. **Felülvizsgálat és létrehozás**, majd **Létrehozás**.
7. A [Foundry portálon](https://ai.azure.com/) telepítsd a `gpt-5.4-mini` vagy a `gpt-5.6-luna` deploymentet, és egy beágyazó modellt. Új indexhez a `text-embedding-3-large` a javasolt. A képzés meglévő `text-embedding-ada-002` deploymentje csak akkor jó, ha az indexet is ezzel építed.

### 2. Azure tárfiók

1. Az Azure Portalon: **Erőforrás létrehozása**.
2. **Tárolás**, majd **Tárfiók**.
3. **Létrehozás**.
4. Redundancia: **LRS**. A régió legyen azonos a keresőszolgáltatással.
5. **Felülvizsgálat és létrehozás**, majd **Létrehozás**.
6. Nyisd meg a tárfiókot, **Adattárolás > Tárolók**.
7. Új tároló.
   - Név: `ai-forras`
   - Névtelen hozzáférés: privát
8. Töltsd fel a dokumentumokat, amelyekből a válaszoknak kell jönniük. Markdown is megfelelő, a képzés segédanyagai ilyenek.

A keresőszolgáltatás felügyelt identitásának **Storage Blob Data Contributor** joga kell ezen a tárfiókon. A saját felhasználódnak is kell blobolvasási jog, ha a portál a bejelentkezett fiókkal listázza a fájlokat.

### 3. Azure AI Search

1. Az Azure Portalon: **Erőforrás létrehozása**.
2. Keress az **Azure AI Search** szolgáltatásra.
3. **Létrehozás**.
4. Töltsd ki a mezőket.
   - Név: `mentor-ai-search`
   - A hely egyezzen a tárfiókéval, és támogassa az agentic retrievalt.
   - Tarifacsomag: **Basic**
5. A Basic díja keresőegységenként óránként számolódik. Az USA keleti régió publikus ára 2026 novemberében 0,101 USD óránként, egy egységgel ez nagyjából havi 74 USD. A forintösszeg az árfolyamtól függ. A szolgáltatás akkor is fizet, ha nem kérdezel. A gyakorlat végén töröld.
6. A Foundry IQ tudásbázisához Basic vagy magasabb kell, mert a felügyelt identitás a Free szinten nem elérhető.
7. **Felülvizsgálat és létrehozás**, majd **Létrehozás**.
8. A keresőn kapcsold be a szerepkör-alapú hozzáférést, és hozz létre rendszer által hozzárendelt felügyelt identitást. A saját felhasználód kapja meg a **Search Service Contributor**, a **Search Index Data Contributor** és a **Search Index Data Reader** szerepet. A Foundry-erőforráson a kereső identitása kapja meg a **Cognitive Services User** szerepet.

### 4. Tudásbázis a saját dokumentumokhoz

Ezt a keresőszolgáltatás oldalán, az **Agentic retrieval** menüben rakod össze. A Foundry **Build > Knowledge** oldala ugyanezt a Foundry IQ réteget nyitja. A portálos Knowledge felület 2026 októberében még előnézet, az API GA része a `2026-04-01`.

1. A `mentor-ai-search` erőforráson: **Agentic retrieval > Knowledge sources**.
2. **Add knowledge source**, majd **Azure blob (Indexed)**.
3. Név: `ai-forras-ks`. Válaszd ki az előfizetést, a tárfiókot és az `ai-forras` tárolót.
4. Hitelesítés: felügyelt identitás, rendszer által hozzárendelt.
5. **Enable text vectorization > Add vectorizer**. Kind: **Microsoft Foundry**. Válaszd ki a projektet és a beágyazó deploymentet. Hitelesítés: rendszer által hozzárendelt identitás.
6. Mentsd a vectorizert, majd hozd létre a knowledge source-t. A portál ettől létrehozza az adatforrást, a skillsetet, az indexet és az indexert.
7. **Agentic retrieval > Knowledge bases > Add knowledge base**.
8. Név: `ai-forras-kb`.
9. **Chat completion model > Add model deployment**. Kind: **Microsoft Foundry**, majd a `gpt-5.4-mini` vagy a `gpt-5.6-luna` deployment. Ha a varázsló ezeket nem kínálja fel, a listában szereplő chat modellt telepítsd a tudásbázishoz. A játszótéri beszélgetéshez a képzés modelljei ettől még megmaradnak. A portál dokumentált listája szűkebb tud lenni, mint a katalógus.
10. Knowledge source: `ai-forras-ks`. Hozd létre a tudásbázist.
11. A tudásbázis chat mezőjében kérdezz rá egy olyan tényre, ami a feltöltött fájlban van. A válasz mellett a forrás hivatkozása is jelenjen meg.
12. **Search management** alatt nézd meg, hogy az indexer hibátlanul lefutott-e. Új fájlnál töltsd fel a blobot, majd futtasd újra az indexert.

### 5. Webalkalmazás

A Chat játszótér **Deploy to a web app** gombja a Foundry classic felülethez tartozik, és a kivezetett On Your Data bekötésre épült. Az új Foundry nézetben ez a gomb nem a saját dokumentumos közzététel útja.

Az új felületen a webes csevegő egy agent. **Build > Agents** alatt létrehozod az agentet, hozzáadod a Foundry IQ tudásbázist, majd verziót készítesz belőle. A webalkalmazás közzététele ehhez a verzióhoz kötődik. A Copilotba és a Teamsbe publikálás 2026 októberében általánosan elérhető. A klasszikus, B1-es App Service-re pakoló űrlap (név, előfizetés, erőforráscsoport, régió, chat history) csak a classic portálon, saját adat nélkül használható biztosan.

A képzés ellenőrzése a tudásbázis chatje és a modell játszótér. Webes közzétételnél az App Service a választott csomag szerint fizet. Ha a kész app Microsoft-bejelentkezést kér, az a bérlőre korlátozott hitelesítés. **Accept** után lehet beszélgetni.

### 6. Példa kérdések

Ezek a feltöltött képzési segédanyagokra kérdeznek rá:

1. Ma már minden a mesterséges intelligenciáról (AI) szól: mit jelent ez számunkra?
2. Hogyan telepítek Node.js 24-et Linuxra, és miért a 24.22.1 a minimum a 2026. októberi javítás óta?
3. Hogyan telepítek Python 3-at Windowsra?
4. Mik a webhook alkalmazási területei?
5. Hogyan néz ki egy Cloud Administrator első napja?
6. Milyen segédanyagokat találok az Azure témájú képzésekhez?
7. Hogyan kapcsolom össze az Azure Pipeline-t a GitHubbal?
