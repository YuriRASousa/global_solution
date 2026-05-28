# 🔥 FireWatch — Monitoramento de Queimadas com Tecnologia Espacial

> Aplicativo móvel híbrido para monitoramento em tempo real de focos de queimadas, 
> integrado a dados satelitais da NASA FIRMS e análise de telemetria orbital.

---

## 📱 Sobre o Projeto

O **FireWatch** é uma solução tecnológica desenvolvida para a **Global Solution 1 — Space Connect (FIAP 2026)**. O projeto foca na democratização do acesso a dados espaciais para o monitoramento ambiental e apoio à Defesa Civil.

O diferencial da solução é a **Sincronização de Telemetria Orbital**: o aplicativo simula e exibe a posição em tempo real dos satélites (como o NOAA-20), sincronizando os dados estatísticos do Dashboard com os marcadores visuais no Mapa, garantindo que a informação de "Próxima Passagem" e "Localização Atual" seja consistente em toda a plataforma.

---

## 🛰️ Funcionalidades Principais

| Funcionalidade | Descrição |
|---|---|
| **Mapa de Vigilância** | Visualização de focos ativos com marcadores de calor e rastreamento orbital do satélite. |
| **Dashboard Estratégico** | KPIs em tempo real, gráficos de tendência semanal e métricas de biomas afetados. |
| **Sincronização de Telemetria** | Posição satelital e dados de varredura unificados entre Mapa e Dashboard. |
| **Central de Alertas** | Notificações categorizadas por severidade com integração para reporte imediato. |
| **Qualidade do Ar (IQAr)** | Monitoramento de PM2.5, PM10 e CO baseado na localização do usuário. |
| **Reporte Colaborativo** | Envio de ocorrências georreferenciadas com fotos e descrição para as brigadas. |

---

## 🛠️ Tecnologias e APIs

- **Flutter 3.x / Dart 3.x** — Interface reativa e multiplataforma.
- **NASA FIRMS API** — Dados reais dos sensores VIIRS (SNPP/NOAA-20) e MODIS.
- **OpenWeatherMap API** — Dados de poluição e qualidade do ar.
- **Provider** — Gerenciamento de estado centralizado e sincronizado.
- **Flutter Map (OSM)** — Renderização de mapas com filtros de matriz de cor (Dark Mode).

---

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                 # Configuração do App e Navegação Centralizada
├── models/
│   ├── fire_focus.dart       # Modelagem de anomalias térmicas (NASA)
│   └── fire_alert.dart       # Entidade de alertas e severidade
├── providers/
│   └── fire_provider.dart    # Estado global e lógica de sincronização
├── services/
│   └── firewatch_service.dart # Integração com APIs e Cálculos Orbitais
├── screens/
│   ├── home_screen.dart      # Mapa e Monitoramento Ativo
│   ├── dashboard_screen.dart # Centro de Comando e Estatísticas
│   ├── alerts_screen.dart    # Gestão de incidentes e notificações
│   └── report_screen.dart    # Formulário de reporte georreferenciado
└── widgets/                  # Componentes reutilizáveis (Cards, Badges, etc)
```

---

## 🚀 Como Executar

### 1. Pré-requisitos
- Flutter SDK instalado.
- Chave de API da [NASA FIRMS](https://firms.modaps.eosdis.nasa.gov/api/config/).

### 2. Configuração de Variáveis de Ambiente
O projeto utiliza `flutter_dotenv` para segurança. Crie um arquivo `.env` na raiz da pasta `flutter_app`:

```env
NASA_FIRMS_API_KEY=sua_chave_aqui
OPENWEATHER_API_KEY=sua_chave_aqui
```

### 3. Instalação e Execução
```bash
# Instalar dependências
flutter pub get

# Executar o projeto
flutter run
```

---

## 🌐 Sincronização de Dados (Lógica de Negócio)

Para evitar disparidade visual, o FireWatch utiliza uma "Fonte Única de Verdade" (*Single Source of Truth*):
1. O `FireWatchService` calcula a posição do satélite baseada no timestamp da última sincronização.
2. O `FireProvider` distribui essas coordenadas para o marcador no `HomeScreen` e para os cartões de telemetria no `DashboardScreen`.
3. Isso garante que, se o Dashboard indica que o satélite está "Cruzando o Brasil Central", o ícone no mapa estará exatamente sobre essa região.

---

## 👥 Equipe — FIAP 2026
Desenvolvido para a Global Solution — Turma 3SIOA.
