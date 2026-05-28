# 🔥 FireWatch — Monitoramento de Queimadas com Tecnologia Espacial

> Aplicativo móvel híbrido para monitoramento em tempo real de focos de queimadas, 
> integrado a dados satelitais da NASA, INPE e ESA.

---

## 📱 Sobre o Projeto

O **FireWatch** é uma solução tecnológica desenvolvida como parte da **Global Solution 1 — Space Connect (FIAP 2026)**, conectando a economia espacial ao monitoramento ambiental.

O app utiliza dados de satélites como **NOAA-20 (VIIRS)**, **Terra/Aqua (MODIS)** e **Sentinel-2** para detectar e monitorar focos de incêndio em tempo real no Brasil, fornecendo alertas inteligentes, análise de qualidade do ar e ferramentas de reporte cidadão para apoio à Defesa Civil.

---

## 🛰️ Funcionalidades

| Funcionalidade | Descrição |
|---|---|
| **Mapa de Focos** | Visualização em tempo real de focos ativos com intensidade e bioma |
| **Central de Alertas** | Alertas categorizados por severidade (Crítico / Alto / Médio / Info) |
| **Dashboard Analítico** | Gráficos de tendência, qualidade do ar (IQAr), breakdown por bioma |
| **Detalhe do Foco** | Temperatura, área, coordenadas GPS, satélite de origem, tendência |
| **Reporte Cidadão** | Envio de ocorrências com foto, localização e descrição |
| **Integração Defesa Civil** | Botão de reporte direto para autoridades competentes |

---

## 🛠️ Tecnologias

- **Flutter 3.x** — Framework híbrido mobile/web
- **Dart 3.x** — Linguagem de programação
- **NASA FIRMS API** — Fire Information for Resource Management System
- **INPE BDQueimadas** — Base de Dados de Queimadas do Brasil
- **OpenWeatherMap Air Pollution API** — Qualidade do ar
- **flutter_map** — Mapas interativos (OpenStreetMap tiles)
- **fl_chart** — Gráficos e visualizações
- **geolocator** — Geolocalização do dispositivo

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada + navegação principal
├── models/
│   ├── fire_focus.dart          # Modelo de foco de queimada
│   └── fire_alert.dart          # Modelo de alerta
├── services/
│   └── firewatch_service.dart   # Integração APIs (NASA FIRMS, INPE, OpenWeather)
├── screens/
│   ├── home_screen.dart         # Tela principal com mapa
│   ├── alerts_screen.dart       # Central de alertas
│   ├── dashboard_screen.dart    # Dashboard analítico
│   ├── report_screen.dart       # Formulário de reporte
│   └── focus_detail_screen.dart # Detalhes de um foco
└── widgets/
    ├── focus_card.dart          # Card reutilizável de foco
    └── risk_badge.dart          # Badge de nível de risco
```

---

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK 3.x instalado → [flutter.dev](https://flutter.dev/docs/get-started/install)
- Android Studio ou VS Code com extensão Flutter
- Dispositivo físico ou emulador Android/iOS

### Passos

```bash
# 1. Clone o repositório
git clone https://github.com/SEU_USUARIO/firewatch.git
cd firewatch

# 2. Configure as plataformas (Android e Web)
# Isso recria as pastas 'android' e 'web' necessárias para compilação
flutter create --platforms=android,web .

# 3. Instale as dependências
flutter pub get

# 4. Configure as API Keys
# Edite lib/services/firewatch_service.dart e insira suas chaves:
# NASA_API_KEY e OPENWEATHER_API_KEY

# 5. Execute o app
flutter run

# Para rodar no navegador:
flutter run -d chrome

# Para gerar o arquivo de instalação (APK):
flutter build apk --release
```

> ⚠️ **Sem API keys**: o app funciona normalmente com dados **mock** representativos.

---

## 🌐 APIs e Fontes de Dados

| API | Fonte | Gratuito | Documentação |
|-----|-------|----------|---|
| NASA FIRMS VIIRS | NASA | ✅ | [firms.modaps.eosdis.nasa.gov](https://firms.modaps.eosdis.nasa.gov/api/) |
| BDQueimadas INPE | INPE | ✅ | [queimadas.dgi.inpe.br](https://queimadas.dgi.inpe.br) |
| Air Pollution API | OpenWeatherMap | ✅ (free tier) | [openweathermap.org](https://openweathermap.org/api/air-pollution) |
| International Charter | Space & Major Disasters | ✅ | [disasterscharter.org](https://disasterscharter.org) |

---

## 👥 Equipe

Desenvolvido para a Global Solution 1 — FIAP 2026  
Curso: Análise e Desenvolvimento de Sistemas  
Turma: 3SIOA

---

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos (FIAP Global Solution 2026).
