# 🏙️ Analisi Disagio Socio-Economico in Italia in Relazione agli Stadi

Piattaforma di web-mapping interattiva per l'analisi spaziale del disagio socio-economico sub-comunale nelle principali città italiane, integrata con la distribuzione geografica delle grandi infrastrutture sportive.

---

## 📌 Descrizione

Il progetto esplora la relazione spaziale tra le condizioni socio-economiche delle popolazioni urbane italiane e la localizzazione delle grandi infrastrutture sportive, assumendo gli stadi come elemento di osservazione privilegiato per indagare il rapporto tra impianti di rilevanza pubblica e contesti territoriali caratterizzati da diversi livelli di disagio.

L'analisi integra dati ISTAT (indice IDISE 2021 e classificazioni ADU) con dati geografici provenienti da shapefile amministrativi e da OpenStreetMap, su un campione di 22 città target italiane.

---

## 🎯 Obiettivi

- Infrastrutturare una procedura automatizzata di estrazione e consolidamento dei dati sul disagio socio-economico sub-comunale (IDISE e classificazione ADU ISTAT 2021) per 22 città target
- Integrare basi dati statistiche tabellari con geodatabase territoriali tramite join spaziale dinamico e differenziato per tipologia (ASC1, ASC2, ASC3)
- Geocodificare e sovrapporre la distribuzione puntuale delle grandi infrastrutture sportive (stadi) alle mappe coropletiche del disagio
- Realizzare una piattaforma interattiva di web-mapping tramite Leaflet che consenta l'esplorazione multi-layer simultanea

---

## 🔬 Metodologia

Per ogni città sono stati raccolti e integrati i dataset ISTAT relativi alle aree sub-comunali (ADU e sezioni censuarie), associando a ciascun codice territoriale le relative informazioni socio-economiche. I confini geografici sono stati importati tramite shapefile e armonizzati attraverso operazioni di pulizia e standardizzazione dei codici identificativi.

L'integrazione spaziale è stata differenziata in base alla tipologia di area (ASC1, ASC2, ASC3) per garantire il corretto aggancio tra dati statistici e geometrie territoriali, trasformate in WGS84 per la visualizzazione su mappa. Gli stadi sono stati estratti da OpenStreetMap e georeferenziati come layer puntuale.

La visualizzazione finale combina tre layer principali: indice IDISE (mappa coropletica), classificazione ADU e localizzazione degli stadi, con controlli dinamici e legende tematiche.

---

## 📊 Risultati principali

- Processato e normalizzato un dataset multivariato sub-comunale per le principali città italiane, strutturando i flussi informativi provenienti da tre diversi modelli di partizione territoriale (ASC1, ASC2, ASC3)
- Eseguito il join geometrico ad alta precisione tra dati statistici e confini cartografici delle sezioni censuarie ISTAT
- Mappata la localizzazione puntuale dei principali stadi italiani in formato GeoJSON (WGS84/EPSG:4326)
- Sviluppato un applicativo cartografico interattivo cross-city con sistema avanzato di Layer Control, legende indipendenti sincronizzate e note metodologiche integrate

---

## 🛠️ Tecnologie utilizzate

- **R** — elaborazione e analisi dei dati
- **sf / tidyverse** — gestione dati geospaziali e join spaziale
- **Leaflet** — mappa interattiva web
- **ISTAT** — dati IDISE 2021 e classificazioni ADU
- **OpenStreetMap / Overpass API** — localizzazione stadi

---

## 📁 Struttura del progetto

```
Analisi-Disagio-Socioeconomico-Italiano/
├── README.md
├── Script ADU_IDISE.R
└── Mappa disagio socio-eco.html
```

> ⚠️ I dati grezzi (shapefile ISTAT, dataset ADU per città) non sono inclusi nel repository per ragioni di dimensione. Le fonti sono indicate nella sezione Dati.

---

## 📂 Dati

| Fonte | Descrizione |
|-------|-------------|
| [ISTAT](https://www.istat.it) | Indice IDISE 2021, classificazioni ADU, sezioni censuarie |
| [OpenStreetMap](https://www.openstreetmap.org) | Localizzazione stadi |

---

## 🔗 Link utili

- 🌐 [Sport Business Lab Consultancy](https://www.sblconsultancy.it/)
