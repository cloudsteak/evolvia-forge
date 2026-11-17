# Alap AI példa Azure-ban

A mesterséges intelligencia továbbra is az egyik leggyakrabban kért téma a felhőben. 2026 októberére az Azure-os belépő már nem az Azure OpenAI Studio, hanem a Microsoft Foundry. Ez az útmutató azt a állapotot írja le: a portált, a modelleket, és azt, hogyan lehet a saját dokumentumainkra válaszoló csevegést összerakni.

## Azure AI 2026 októberében

A fejlesztői felület a [Microsoft Foundry](https://ai.azure.com/). A korábbi nevek (Azure OpenAI Studio, Azure AI Studio, Azure AI Foundry) ugyanerre a platformra vonatkoznak. A portál tetején a **New Foundry** kapcsolóval az új felületet használd. A modellhívás tokenenként számlázott, a portál megnyitása önmagában nem ingyenes.

Amit ezen a képzésen használunk:

- **Microsoft Foundry** a modellek telepítésére és a játszótérre. A háttérerőforrás típusa továbbra is `Microsoft.CognitiveServices/accounts`. A portálon ez Foundry-erőforrás és projekt. A régebbi, külön Azure OpenAI-fiók ugyanebbe a típusba tartozik, és átvihető Foundry-erőforrásra.
- **Foundry Tools** a kész AI-képességek. Ez a vonal volt korábban az Azure Cognitive Services, majd az Azure AI Services. Ide tartozik a Speech, a Translator, a Language, a Vision, a Document Intelligence, a Content Understanding és a Content Safety. A Decision és a Web Search kategória már nincs a kínálatban. Az Anomaly Detector, a Personalizer, a Content Moderator, a LUIS és a QnA Maker kivezetett szolgáltatás.
- **Azure AI Search**, a portálon Foundry IQ néven is. Ez adja a saját dokumentumok indexelését és a tudásbázist.
- **Azure Machine Learning** és **Azure Databricks** külön adat- és modellplatform. Új csevegőalkalmazást a Foundry Agent Service-ben érdemes kezdeni. Az Assistants API 2026. augusztus 26-án megszűnt.

A képzés egy chat modellt telepít, Global standard típusban:

- `gpt-5-mini`, verzió `2025-08-07`. A gyakorló csevegéshez ez a modell van telepítve.

A katalógusban 2026 októberére a GPT-5.5, a GPT-5.6 (`sol`, `terra`, `luna`) és a GPT-6 vonal is elérhető. Ezen a képzésen a `gpt-5-mini` és a `text-embedding-3-large` deploymenttel dolgozunk.

## Hogyan kezdjük el?

Nyisd meg a [Microsoft Foundry](https://ai.azure.com/) portált, és kapcsold be a **New Foundry** nézetet. A modell csak akkor hívható, ha készült hozzá deployment. A deployment neve az, amit a kérés `model` mezőjében megadsz.

### Deployment létrehozása

1. A Foundry portálon menj a **Build > Catalog > Model Catalog** oldalra.
2. Válaszd a `gpt-5-mini` modellt.
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

A képzési fájlok a lab indulásakor felkerülnek a Foundry projektbe, és bekerülnek a `ceges-dokumentumok` vektorindexbe. Az **Adatok > Adatkészletek** alatt `assistant-` kezdetű névvel látod a fájlokat. Saját gépről nem kell feltölteni, és tárfiókot sem kell választani.

1. Nyisd meg a [Foundry portált](https://ai.azure.com/), és a `gpt-5-mini` demókörnyezetét.
2. **Hozzáadás**, majd **Fájlkeresés**.
3. **Indexbeállítás**: a `ceges-dokumentumok` index. Fájlt ne húzz be a gépről.
4. **Csatolás**, majd kérdezz rá egy olyan tényre, ami a fájlban van. A válasz a feltöltött anyagból jöjjön.

### Webalkalmazás

A Chat játszótér **Deploy to a web app** gombja a Foundry classic felülethez tartozik, és a kivezetett On Your Data bekötésre épült. Az új Foundry nézetben ez a gomb nem a saját dokumentumos közzététel útja.

Az új felületen a webes csevegő az ügynök. A képzés ellenőrzése az ügynök beszélgetése: a válasz a projektben lévő fájlból jöjjön.

### Példa kérdések

Ezek a feltöltött képzési segédanyagokra kérdeznek rá:

1. Ma már minden a mesterséges intelligenciáról (AI) szól: mit jelent ez számunkra?
2. Hogyan telepítek Node.js 24-et Linuxra, és miért a 24.22.1 a minimum a 2026. októberi javítás óta?
3. Hogyan telepítek Python 3-at Windowsra?
4. Mik a webhook alkalmazási területei?
5. Hogyan néz ki egy Cloud Administrator első napja?
6. Milyen segédanyagokat találok az Azure témájú képzésekhez?
7. Hogyan kapcsolom össze az Azure Pipeline-t a GitHubbal?
