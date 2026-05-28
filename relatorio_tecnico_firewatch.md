# 🔥 FireWatch
## Monitoramento de Queimadas com Tecnologia Espacial

**Relatório Técnico — Global Solution 1 — Space Connect**

| | |
|---|---|
| **Curso** | Análise e Desenvolvimento de Sistemas |
| **Turma** | 3SIOA |
| **Instituição** | FIAP |
| **Período** | Maio / Junho de 2026 |
| **Tema** | Monitoramento Ambiental com Tecnologia Espacial |
| **Tecnologia** | Flutter (Dart) — Aplicativo híbrido mobile/web |

---

## Sumário

1. [Contextualização do Problema](#1-contextualização-do-problema)
2. [Proposta da Solução](#2-proposta-da-solução)
3. [Arquitetura da Aplicação](#3-arquitetura-da-aplicação)
4. [Diagrama BPMN](#4-diagrama-bpmn--processo-principal)
5. [Mockups das Telas](#5-mockups-das-telas-principais)
6. [Tecnologias e Ferramentas](#6-tecnologias-e-ferramentas)
7. [Análise de Impacto e Viabilidade](#7-análise-de-impacto-e-viabilidade)
8. [Links e Referências](#8-links-e-referências)

---

## 1. Contextualização do Problema

### 1.1 Cenário Ambiental

O Brasil enfrenta anualmente uma crise crescente de queimadas e incêndios florestais que devastam biomas inteiros, especialmente o Cerrado, a Amazônia e a Mata Atlântica. Segundo o INPE, somente em 2023 foram registrados mais de **196.000 focos de incêndio** em território nacional, colocando o país entre os maiores emissores de carbono por desmatamento e queimadas do mundo.

Os impactos são multidimensionais: destruição de ecossistemas, perda de biodiversidade, emissão massiva de CO₂, degradação da qualidade do ar em regiões urbanas e rurais, prejuízos à agricultura e riscos à saúde pública — internações por doenças respiratórias aumentam de forma significativa nos períodos de queimadas, afetando especialmente crianças e idosos.

### 1.2 Papel da Tecnologia Espacial

A detecção remota por satélite é atualmente a principal ferramenta para monitoramento de queimadas em escala nacional e global. Satélites como o **NOAA-20** (sensor VIIRS, resolução de 375m), **Terra e Aqua** (sensor MODIS, resolução de 1km) e **Sentinel-2** (sensor MSI, resolução de 10m) orbitam a Terra diariamente, capturando radiância infravermelha que permite identificar focos ativos com alta precisão.

O **INPE** opera o BDQueimadas, consolidando dados dessas fontes e disponibilizando via API pública. A **NASA** opera o FIRMS (Fire Information for Resource Management System), que processa e distribui dados em tempo quase-real. Combinadas com interfaces mobile acessíveis, essas fontes abertas têm o potencial de transformar a resposta a desastres no país.

### 1.3 Conexão com a International Charter

O projeto se alinha diretamente à iniciativa **"The International Charter: Space and Major Disasters"**, que reúne agências espaciais globais para fornecer imagens satelitais em resposta a grandes desastres. O FireWatch atua como interface de consumo desses dados para cidadãos, gestores municipais e equipes da Defesa Civil, democratizando o acesso à informação espacial em situações de emergência.

---

## 2. Proposta da Solução

### 2.1 Visão Geral

O **FireWatch** é um aplicativo móvel híbrido (Android, iOS e Web) desenvolvido em **Flutter**, que integra dados satelitais em tempo real para monitoramento de queimadas no Brasil. A solução foi projetada para três perfis de usuário:

- **Cidadão comum** — alertas de proximidade, reporte colaborativo e informações de qualidade do ar
- **Gestor municipal** — dashboard analítico, histórico de ocorrências e geração de relatórios
- **Defesa Civil** — recebimento de reportes, despacho de equipes e atualização de status

### 2.2 Requisitos Funcionais

| ID | Requisito |
|----|-----------|
| RF01 | Exibir mapa interativo com focos de queimadas ativas em tempo real, com código de cores por nível de risco |
| RF02 | Receber e exibir alertas push categorizados por severidade (Crítico / Alto / Médio / Informativo) |
| RF03 | Exibir detalhes de cada foco: temperatura, área estimada, satélite de origem, bioma, estado e coordenadas GPS |
| RF04 | Apresentar dashboard analítico com tendências semanais, qualidade do ar (IQAr) e distribuição por bioma |
| RF05 | Permitir reporte colaborativo de ocorrências com localização automática, foto e descrição |
| RF06 | Enviar relatórios diretamente à Defesa Civil municipal via integração de notificação |
| RF07 | Exibir status dos satélites ativos e próximas passagens sobre o Brasil |
| RF08 | Suportar modo offline com dados em cache da última sincronização bem-sucedida |

### 2.3 Requisitos Não Funcionais

| ID | Requisito |
|----|-----------|
| RNF01 | Tempo de resposta máximo de 3 segundos para carregamento dos focos ativos |
| RNF02 | Disponibilidade mínima de 99,5% (exceto janelas de manutenção programada) |
| RNF03 | Compatibilidade com Android 8.0+ e iOS 13+ |
| RNF04 | Dados de localização criptografados e não compartilhados com terceiros |
| RNF05 | Interface acessível conforme diretrizes WCAG AA (contraste mínimo 4.5:1) |
| RNF06 | Atualização de dados a cada 10 minutos, alinhada ao ciclo orbital do VIIRS |

---

## 3. Arquitetura da Aplicação

### 3.1 Visão em Camadas

O FireWatch adota a arquitetura **MVC adaptada ao padrão Flutter**, com separação clara entre Screens (View + Controller) e Services (Model). As camadas são:

```
┌─────────────────────────────────────────────────────┐
│                   APRESENTAÇÃO                       │
│   HomeScreen  AlertsScreen  Dashboard  ReportScreen  │
├─────────────────────────────────────────────────────┤
│             ESTADO E LÓGICA (Providers)              │
│         FireProvider (ChangeNotifier / Pull)         │
├─────────────────────────────────────────────────────┤
│                  COMPONENTES (Widgets)                │
│        FocusCard   RiskBadge   TrendChart            │
├─────────────────────────────────────────────────────┤
│                   SERVIÇOS                           │
│           FireWatchService  (integração APIs)        │
├─────────────────────────────────────────────────────┤
│                    MODELOS                           │
│       FireFocus   FireAlert   AirQualityData         │
├─────────────────────────────────────────────────────┤
│                  APIs EXTERNAS                       │
│   NASA FIRMS (VIIRS/MODIS)   INPE   OpenWeatherMap   │
└─────────────────────────────────────────────────────┘
```

### 3.2 Estrutura de Diretórios

```
lib/
├── main.dart                      # Ponto de entrada + navegação bottom bar
├── models/
│   ├── fire_focus.dart            # Entidade: foco de queimada + enum FireRisk
│   └── fire_alert.dart            # Entidade: alerta + severidade + status
├── providers/
│   └── fire_provider.dart         # Gerenciamento de estado e sincronização global
├── services/
│   └── firewatch_service.dart     # Integração NASA FIRMS, INPE, OpenWeather
├── screens/
│   ├── home_screen.dart           # Mapa principal com focos em tempo real
│   ├── alerts_screen.dart         # Central de alertas por severidade
│   ├── dashboard_screen.dart      # Dashboard analítico com gráficos
│   ├── report_screen.dart         # Formulário de reporte de ocorrência
│   └── focus_detail_screen.dart   # Detalhes completos de um foco
└── widgets/
    ├── focus_card.dart            # Card reutilizável de foco de queimada
    └── risk_badge.dart            # Badge de nível de risco com cores semânticas
```

### 3.3 Fluxo de Dados

O app segue o padrão **pull com cache local**:

1. Na inicialização, o app verifica conectividade e requisita dados frescos da NASA FIRMS
2. Os dados são parseados do formato CSV para objetos `FireFocus` com nível de risco calculado
3. Em paralelo, o `FireWatchService` busca dados de qualidade do ar na OpenWeatherMap
4. Todos os dados são armazenados via `SharedPreferences` para funcionamento offline
5. Um timer interno dispara nova sincronização a cada **10 minutos** (ciclo VIIRS)
6. Em caso de foco de alto risco próximo ao usuário, uma notificação push é gerada localmente

### 3.4 Integração Satelital

A integração principal é com a **NASA FIRMS API**, que retorna CSV em tempo quase-real com os campos:

| Campo | Descrição |
|-------|-----------|
| `latitude / longitude` | Coordenadas do centro do pixel |
| `brightness` | Temperatura de brilho em Kelvin (sensor VIIRS) |
| `frp` | Fire Radiative Power — potência radiativa do fogo (MW) |
| `satellite` | Satélite de origem (N = NOAA-20, T = Terra, A = Aqua) |
| `acq_date / acq_time` | Data e hora UTC da aquisição |
| `confidence` | Nível de confiança da detecção (nominal/high/low) |

O FireWatch classifica cada foco em um dos quatro níveis de risco com base na temperatura:

| Temperatura | Nível de Risco |
|-------------|----------------|
| > 480 K | 🔴 Crítico |
| 400–480 K | 🟠 Alto |
| 340–400 K | 🟡 Médio |
| < 340 K | 🟢 Baixo |

### 3.5 Sincronização de Telemetria Orbital

Um diferencial técnico implementado é a **sincronização determinística da telemetria**. Para garantir consistência visual, a posição do satélite exibida no mapa (`HomeScreen`) é calculada centralizadamente no `FireWatchService` com base no ciclo orbital de 60 minutos e injetada no `FireProvider`. Isso garante que a descrição regional no Dashboard e o marcador no mapa estejam sempre em conformidade, evitando drift de dados entre telas.

---

## 4. Diagrama BPMN — Processo Principal

### Processo: Detecção e Resposta a Foco de Queimada

O processo cobre o ciclo completo desde a passagem do satélite até o encerramento da ocorrência pela Defesa Civil. É composto por **5 raias** (pools):

---

**Raia 1 — Satélite (NASA / INPE)**

```
[Início] → (Passagem orbital) → [Captura imagem IR] → [Processa radiância]
        → <Foco detectado?> --Não--> [Descarta frame] → (Próxima passagem)
                            --Sim--> [Publica na API FIRMS] →→→
```

---

**Raia 2 — FireWatch Backend**

```
→→→ (Timer 10min) → [Polling NASA FIRMS API] → [Filtra focos novos]
    → [Calcula nível de risco] → [Persiste no banco] 
    → <Risco alto/crítico?> --Não--> [Atualiza mapa silenciosamente]
                            --Sim--> [Dispara notificação push] →→→
```

---

**Raia 3 — Usuário (App)**

```
→→→ (Recebe notificação) → [Abre app] → [Visualiza foco no mapa]
    → [Consulta detalhes do foco] → <Quer reportar?> --Não--> [Fim]
                                                     --Sim--> →→→
```

---

**Raia 4 — Usuário (Reporte)**

```
→→→ [Abre formulário] → [Seleciona tipo de ocorrência] 
    → [Confirma localização GPS] → [Adiciona foto (opcional)]
    → [Preenche descrição] → [Envia relatório] →→→
```

---

**Raia 5 — Defesa Civil**

```
→→→ (Recebe relatório) → [Avalia prioridade] → [Despacha equipe de campo]
    → [Equipe atende ocorrência] → [Atualiza status no sistema]
    → [Foco marcado como resolvido] → (Usuário recebe confirmação) → [Fim]
```

---

> O arquivo `.bpmn` para importação no Camunda Modeler ou Bizagi está disponível no repositório GitHub em `/docs/bpmn/firewatch_main_process.bpmn`.

---

## 5. Mockups das Telas Principais

### Tela 1 — Mapa Principal (`HomeScreen`)

A tela inicial exibe o mapa interativo do Brasil com marcadores coloridos para cada foco ativo. No topo, o cabeçalho mostra o nome do app, a localização do usuário e um badge de alerta quando há focos críticos próximos. Abaixo do mapa, três cards de estatísticas exibem o total de focos do dia, a quantidade em alto risco e o número de satélites ativos. Uma barra de filtros horizontal permite filtrar focos por nível de risco. A lista abaixo traz os `FocusCard` com informações resumidas de cada foco, ordenados por severidade.

**Componentes:** `flutter_map`, `FocusCard`, `RiskBadge`, `StatCard`, filtros de chip

---

### Tela 2 — Central de Alertas (`AlertsScreen`)

Lista de alertas ordenada cronologicamente, com destaque visual por cor de acordo com a severidade. Cada `AlertTile` exibe ícone de severidade, título, descrição resumida, localização, distância do usuário e tempo decorrido. Alertas ativos possuem botões de ação rápida: "Ver no mapa" e "Reportar". Alertas resolvidos exibem um indicador verde de conclusão.

**Componentes:** `AlertTile`, `ActionButton`, badges de severidade com cores semânticas

---

### Tela 3 — Dashboard Analítico (`DashboardScreen`)

Painel de análise com quatro seções: (1) cards KPI com total de focos, área afetada e alertas ativos; (2) gráfico de barras com focos por dia da semana atual; (3) barra de progresso do IQAr (Índice de Qualidade do Ar) com escala de Bom a Perigoso e métricas de PM2.5, PM10 e CO; (4) barras horizontais com distribuição de focos por bioma (Cerrado, Amazônia, Mata Atlântica); (5) lista de satélites ativos com status e próxima passagem.

**Componentes:** `fl_chart`, `LinearProgressIndicator`, `KpiCard`, `SatelliteStatusRow`

---

### Tela 4 — Detalhe do Foco (`FocusDetailScreen`)

Tela de detalhamento de um foco específico. Exibe no topo uma visualização da imagem satelital (via NASA FIRMS). Abaixo, um grid 2x3 com as métricas do foco: temperatura de brilho, área estimada em hectares, satélite de origem, bioma, estado e nível de risco. Em seguida, as coordenadas GPS exatas em formato legível. Um gráfico de linha mostra a tendência de intensidade nas últimas 6 horas. O botão de ação principal envia um relatório diretamente à Defesa Civil com um toque.

**Componentes:** `CustomPaint` (gráfico de tendência), `InfoGrid`, `CoordinateCard`

---

### Tela 5 — Reportar Ocorrência (`ReportScreen`)

Formulário de reporte colaborativo. O usuário seleciona o tipo de ocorrência (Queimada / Fumaça suspeita / Desmatamento / Outro) via chips. A localização é preenchida automaticamente via GPS. Um campo de texto livre permite descrever o que está sendo visto. Um botão de câmera permite adicionar uma foto. Após o envio, a tela exibe uma confirmação com número de protocolo e informa que o relatório foi encaminhado à equipe de monitoramento.

**Componentes:** `geolocator`, `image_picker`, `TextField`, confirmação de envio

---

## 6. Tecnologias e Ferramentas

| Tecnologia | Versão | Função no Projeto |
|------------|--------|-------------------|
| Flutter | 3.x | Framework principal — interface mobile/web híbrida |
| Dart | 3.x | Linguagem de programação |
| NASA FIRMS API | v1 | Dados VIIRS/MODIS de focos em tempo quase-real |
| OpenWeatherMap | v2.5 | Índice de Qualidade do Ar (IQAr) por coordenada |
| flutter_map | 7.x | Mapa interativo com tiles OpenStreetMap |
| fl_chart | 0.67 | Gráficos de barras, linhas e indicadores |
| geolocator | 11.x | Geolocalização GPS do dispositivo |
| provider | 6.x | Gerenciamento de estado reativo |
| flutter_dotenv | 5.x | Gestão segura de chaves de API |
| http | 1.2 | Requisições HTTP/REST às APIs externas |

### Ferramentas de Desenvolvimento

| Ferramenta | Uso |
|------------|-----|
| Android Studio / VS Code | IDE principal com extensão Flutter |
| Git + GitHub | Controle de versão e repositório público |
| Figma | Prototipação e design das telas |
| Postman | Testes das integrações com APIs externas |
| Camunda Modeler | Modelagem do diagrama BPMN |

---

## 7. Análise de Impacto e Viabilidade

### 7.1 Impacto Ambiental e Social

O FireWatch endereça um problema crítico e crescente para o Brasil. A detecção precoce de focos pode reduzir significativamente o tempo de resposta das brigadas de combate a incêndio, limitando a área afetada e os danos ambientais. Estudos de sistemas similares implementados em outros países indicam redução de **até 40% na área média afetada** quando há comunicação rápida entre cidadão e Defesa Civil.

O componente de reporte colaborativo cria uma rede de monitoramento descentralizada que amplia a cobertura além dos sensores satelitais — especialmente relevante em áreas com cobertura de nuvens ou nos intervalos entre passagens orbitais.

### 7.2 Viabilidade Técnica

Todas as APIs utilizadas são gratuitas e possuem documentação pública consolidada:

- A **NASA FIRMS** oferece dados VIIRS gratuitos para até 5.000 requisições por dia — suficiente para uma aplicação de escala nacional inicial
- O **Flutter** garante um único código-base para Android, iOS e Web, reduzindo o custo de desenvolvimento em aproximadamente 60% em relação a apps nativos separados
- A stack escolhida é amplamente adotada pelo mercado, facilitando manutenção e contratação de equipe futura

### 7.3 Viabilidade Econômica

O modelo de negócio prevê três camadas de monetização:

| Plano | Público-alvo | Funcionalidades |
|-------|-------------|-----------------|
| **Gratuito** | Cidadão comum | Mapa, alertas, reporte básico, IQAr |
| **Premium** | Prefeituras e gestores | Dashboard avançado, histórico, relatórios exportáveis, API própria |
| **Enterprise** | Seguradoras, agronegócio | Integração com sistemas legados, alertas customizados, SLA garantido |

O custo de infraestrutura inicial estimado é de **R$ 800/mês** em cloud (AWS ou Google Cloud Platform), escalável conforme crescimento da base de usuários.

### 7.4 Alinhamento Estratégico

O FireWatch se alinha com:

- **Plano Nacional de Enfrentamento às Queimadas (PNAQ 2023–2027)** — Governo Federal
- **Política Nacional de Proteção e Defesa Civil (PNPDEC)** — Lei nº 12.608/2012
- **ODS 13 — Ação Climática** (Agenda 2030 da ONU)
- **ODS 15 — Vida Terrestre** (Agenda 2030 da ONU)
- **International Charter: Space and Major Disasters** — uso de dados satelitais para resposta a desastres

---

## 8. Links e Referências

### 8.1 Repositório e Vídeos

| Item | Link |
|------|------|
| Repositório GitHub | `https://github.com/SEU_USUARIO/firewatch` |
| Vídeo Pitch (Comercial) | *[inserir link YouTube após gravação]* |
| Vídeo Técnico | *[inserir link YouTube após gravação]* |

> Substitua os links acima pelos valores reais antes da entrega final.

### 8.2 Referências Bibliográficas

- INPE. **BDQueimadas**. Disponível em: https://queimadas.dgi.inpe.br. Acesso em: mai. 2026.

- NASA. **FIRMS — Fire Information for Resource Management System**. Disponível em: https://firms.modaps.eosdis.nasa.gov. Acesso em: mai. 2026.

- AGÊNCIA ESPACIAL BRASILEIRA (AEB). Página inicial. Disponível em: https://www.gov.br/aeb/pt-br. Acesso em: mai. 2026.

- CHARTER INTERNACIONAL SPACE & MAJOR DISASTERS. Homepage. Disponível em: https://disasterscharter.org. Acesso em: mai. 2026.

- EUROPEAN SPACE AGENCY (ESA). Sentinel-2 MSI Technical Guide. Disponível em: https://www.esa.int. Acesso em: mai. 2026.

- FLUTTER. **Flutter Documentation**. Disponível em: https://docs.flutter.dev. Acesso em: mai. 2026.

- OPENWEATHERMAP. **Air Pollution API**. Disponível em: https://openweathermap.org/api/air-pollution. Acesso em: mai. 2026.

- BRASIL. Lei nº 12.608, de 10 de abril de 2012. **Institui a Política Nacional de Proteção e Defesa Civil (PNPDEC)**. Brasília, DF: Presidência da República, 2012.

---

*Documento elaborado para fins acadêmicos — FIAP Global Solution 1 — Space Connect — 2026*
