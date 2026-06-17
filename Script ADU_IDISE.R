library(readxl)
library(dplyr)
library(sf)
library(leaflet)
library(htmltools)

#Lista città per tipologia ASCI

citta_asc1 <- c(
  "Venezia",
  "Padova",
  "Gorizia",
  "Trieste",
  "Parma",
  "Modena",
  "Taranto",
  "Reggio Calabria",
  "Messina",
  "Catania",
  "Cagliari"
)
citta_asc2 <- c(
  "Torino",
  "Milano",
  "Verona",
  "Firenze",
  "Napoli",
  "Bari",
  "Prato"
)
citta_asc3 <- c(
  "Genova",
  "Bologna",
  "Roma",
  "Palermo"
)
citta <- c(citta_asc1, citta_asc2, citta_asc3)

#Caricamento file

leggi_adu <- function(nome_citta) {
  df <- read_excel(paste0("C:/Users/simon/Desktop/datidis/", 
                          nome_citta, "_IDISE_2021_ADU.xlsx"))
  df$citta <- nome_citta
  return(df)
}

leggi_sez <- function(nome_citta) {
  df <- read_excel(paste0("C:/Users/simon/Desktop/datidis/",
                          nome_citta, "_2021_SEZ_ADU.xlsx"))
  df$citta <- nome_citta
  return(df)
}

leggi_asc <- function(nome_citta) {
  df <- read_excel(paste0("C:/Users/simon/Desktop/datidis/",
                          nome_citta, "_IDISE_2021_ASC.xlsx"))
  df$citta <- nome_citta
  return(df)
}

adu  <- bind_rows(lapply(citta, leggi_adu))
sez  <- bind_rows(lapply(citta, leggi_sez))
data <- bind_rows(lapply(citta, leggi_asc))

data <- data[,c(3,4,14, ncol(data))]
data <- na.omit(data)

data$COD_ASC <- as.character(data$COD_ASC)

cartella <- "C:/Users/simon/Desktop/shp/"

files_shp <- list.files(cartella, 
                        pattern = "\\.shp$", 
                        full.names = TRUE)

basi <- do.call(rbind, lapply(files_shp, st_read))

basi <- basi %>%
  mutate(
    COM_ASC1 = as.character(COM_ASC1),
    COM_ASC2 = as.character(COM_ASC2),
    COM_ASC3 = as.character(COM_ASC3)
  )

#Join differenziato per ASCI

basi_asc1 <- basi %>%
  filter(COM_ASC1 %in% data$COD_ASC) %>%
  group_by(COM_ASC1) %>%
  summarise()

basi_asc2 <- basi %>%
  filter(COM_ASC2 %in% data$COD_ASC) %>%
  group_by(COM_ASC2) %>%
  summarise()

basi_asc3 <- basi %>%
  filter(COM_ASC3 %in% data$COD_ASC) %>%
  group_by(COM_ASC3) %>%
  summarise()

df_asc1 <- data %>%
  filter(citta %in% citta_asc1) %>%
  left_join(basi_asc1, by = join_by(COD_ASC == COM_ASC1))

df_asc2 <- data %>%
  filter(citta %in% citta_asc2) %>%
  left_join(basi_asc2, by = join_by(COD_ASC == COM_ASC2))

df_asc3 <- data %>%
  filter(citta %in% citta_asc3) %>%
  left_join(basi_asc3, by = join_by(COD_ASC == COM_ASC3))

df <- bind_rows(df_asc1, df_asc2, df_asc3)

df <- st_as_sf(df)
df <- st_transform(df, 4326)

prova <- left_join(sez, adu, by = join_by(COD_ADU21))

basi2 <- basi %>%
  mutate(SEZ21_ID = as.character(SEZ21_ID)) %>%
  filter(SEZ21_ID %in% prova$SEZIONE) %>%
  group_by(SEZ21_ID) %>%
  summarise()

df2 <- left_join(prova, basi2, by = join_by(SEZIONE == SEZ21_ID))

df2 <- st_as_sf(df2)

df2 <- df2 %>%
  group_by(COD_ADU21) %>%
  summarise(
    tipo = first(TIPO_ADU21),
    .groups = "drop"
  ) %>%
  st_transform(4326)

#Costruzione palette

pal <- colorNumeric(
  palette = colorRampPalette(
    c("#1a9641", "#a6d96a", "#ffffbf", "#fdae61", "#d7191c")
  )(100),
  domain = df$IDISE,
  na.color = "#eeeeee"
)

pal2 <- colorFactor(
  palette = c("#deebf7", "#6baed6", "#08306b"),
  domain = c(1,2,3),
  na.color = "#eeeeee"
)

#Mappe

df  <- st_cast(df, "MULTIPOLYGON")
df2 <- st_cast(df2, "MULTIPOLYGON")

stadi <- st_read("export.geojson")
stadi <- st_transform(stadi, 4326)

nota <- HTML('
<div style="
  background-color: rgba(255,255,255,0.9); 
  padding: 10px; 
  max-width: 300px; 
  max-height: 150px; 
  overflow-y: auto; 
  font-size: 12px; 
  box-shadow: 0px 0px 8px rgba(0,0,0,0.3);
">
<strong>Nota metodologica:</strong><br>
Il progetto integra l’analisi del disagio socio‑economico sub‑comunale (ISTAT 2021) con la distribuzione spaziale delle grandi infrastrutture sportive (stadi) sul territorio nazionale.<br><br>

<strong>Layer tematici analizzati</strong><br>
1. <u>IDISE (2021)</u>:<br>
&nbsp;&nbsp;&nbsp;&nbsp;• Indice di Disagio Socio‑Economico per Aree Sub‑Comunali (ASC).<br>
2. <u>Classificazione ADU</u>:<br>
&nbsp;&nbsp;&nbsp;&nbsp;• Aree urbane caratterizzate da differente concentrazione di disagio (livelli 1, 2, 3).<br>
3. <u>Stadi Italiani</u>:<br>
&nbsp;&nbsp;&nbsp;&nbsp;• Localizzazione puntuale degli impianti sportivi estratti da OpenStreetMap.<br><br>

<strong>Metodo di aggregazione territoriale</strong><br>
• Integrazione di dati statistici ISTAT (Excel) e geografici (Shapefile/OSM) in ambiente R.<br>
• <u>Join spaziale</u>: Applicazione di una logica differenziata per le città ASC1, ASC2 e ASC3 per l’aggancio corretto dei confini sub‑comunali.<br>
• <u>Geocodifica</u>: I dati degli stadi sono stati processati come coordinate puntuali (WGS84) per la sovrapposizione ai poligoni amministrativi.<br><br>

<strong>Visualizzazione</strong><br>
• Mappa interattiva <i>Leaflet</i> con gestione a livelli (Layer Control).<br>
• Gli stadi sono visualizzati tramite marker puntuali sovrapposti alle mappe coropletiche del disagio e delle zone ADU per favorire analisi di prossimità urbana.<br><br>

<strong>Strumenti e Fonti</strong><br>
• R (readxl, dplyr, sf, leaflet, osmdata)<br>
• <u>Dati</u>: ISTAT (IDISE 2021), OpenStreetMap (OSM) per la distribuzione degli impianti sportivi.<br><br>

<strong>Limitazioni</strong><br>
• La copertura degli stadi dipende dalla completezza del database OpenStreetMap al momento del fetch.<br>
• L’indice IDISE e la classificazione ADU seguono le metodologie sperimentali ISTAT 2021.<br>
</div>
')

logo <- tags$a(
  href = "https://sblconsultancy.it/", target = "_blank",
  tags$img(
    src = "https://portiamovalore.uniba.it/uploads/loghi/LinkedIn%20Logo_1639558059.png",
    style = "height:60px;"
  )
)

mappa1 <- leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  
  addPolygons(
    data = df,
    fillColor = ~pal(IDISE),
    weight = 0.2,
    color = "white",
    fillOpacity = 0.8,
    label = ~paste0(COD_ASC, ": ", IDISE),
    group = "IDISE"
  ) %>%
  
  addPolygons(
    data = df2,
    fillColor = ~pal2(tipo),
    weight = 1,
    color = "black",
    fillOpacity = 0.7,
    label = ~tipo,
    group = "ADU"
  ) %>%
  addCircleMarkers(
    data = stadi,
    radius = 4,
    color = "black",
    fillColor = "#A18CD1",
    fillOpacity = 0.8,
    weight = 1,
    popup = ~paste0("<b>", name, "</b>"),
    group = "Stadi"
  )%>%
  addLegend(
    pal = pal,
    values = df$IDISE,
    title = "IDISE",
    position = "bottomright",
    group = "IDISE"
  )%>%
  addLegend(
    pal = pal2,
    values = df2$tipo,
    title = "Tipo ADU",
    position = "bottomright",
    group = "ADU"
  )%>%
  
  addLayersControl(
    overlayGroups = c("IDISE", "ADU", "Stadi"),
    options = layersControlOptions(collapsed = FALSE),
    position = "topleft"
  )%>%
  addControl("<h3>Indice di disagio socio-economico sub comunale</h3>", position = "topright") %>%
  addControl(nota, position = "bottomleft") %>%
  addControl(html = as.character(logo), position = "bottomleft")

mappa1

