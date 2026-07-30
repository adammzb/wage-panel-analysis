# wage-panel-analysis

Panel analysis of average annual wages across OECD countries, 2005–2017.

A balanced country–year panel (38 countries × 13 years) built in Stata from
three sources — OECD average annual wages, OECD exchange rates, and the World
Bank's World Development Indicators — used to describe how average wages covary
with education, employment structure, inequality, gender participation gaps and
unemployment.

## Context

Originally completed as a project for a course at the
University of Tübingen. This repository contains
the Stata code. A Python reimplementation is planned as a follow-up.

## Repository

- `masterfile.do` — runs the whole project end to end (calls the three scripts in order).
- `01_data_cleaning.do` — imports the raw sources, reshapes the WDI data, merges everything into one country–year panel, and builds wage-in-USD and its log.
- `02_descriptives.do` — summary statistics, missingness, correlations, and the pooled-OLS / fixed-effects / two-way fixed-effects panel regressions.
- `03_graphs.do` — all figures reported in the analysis.

## Data

The raw data are not included in this repository. They can be downloaded from:

- OECD — Average annual wages, and PPPs & exchange rates: https://data-explorer.oecd.org/
- World Bank — World Development Indicators: https://databank.worldbank.org/source/world-development-indicators

## Main findings

- The wage distribution is bimodal: a persistent low-wage and a persistent high-wage cluster.
- Wages rise with tertiary attainment, the services employment share and female participation, and fall with unemployment.
- The raw negative wage–inequality correlation reverses sign once labour productivity is held fixed — a development effect rather than a within-country one.
