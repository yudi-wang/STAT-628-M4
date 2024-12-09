#  Project: Descriptive Analysis of Podcast on spotify data
Yuchen Xu, Yudi Wang.

## Description
This project analyzes podcast episodes using descriptive text data. The dataset originally contained 11 columns, including key fields such as show_name, name (episode title), description (text data), category, and show_id. Key cleaning steps included verifying and addressing duplicates, tokenizing description text, and removing stop words for meaningful analysis. The cleaned dataset comprises 20 categories and 368,955 episodes.

## Repository Structure

### 1. Code
- **628 M4 download.ipynb**:
  - Download raw spotify data.
- **process_data_showname.ipynb**:
  - Data cleaning and PCA.
- **Plot.ipynb**:
  - visualization.
- **app.R**:
  - shiny.

### 2. Data
- **episode_pca_scores_filtered.csv**:[Link](https://drive.google.com/drive/folders/1v58ex2g1cIhyhanGa5GJoaqEuNIUv4dI?dmr=1&ec=wgc-drive-hero-goto) Contains raw episode data.
- **cleaned_descriptions.csv**:[Link](https://drive.google.com/drive/folders/1v58ex2g1cIhyhanGa5GJoaqEuNIUv4dI?dmr=1&ec=wgc-drive-hero-goto) Contains raw weather data.
- **episode_pca_scores_filtered.rds**:

### 3. Image
- Contains various images and plots generated during the data analysis and modeling stages.

### 4. Summary
- A document summarizing the key steps in data cleaning and metrics building from the project.

## Shiny Link
The Shiny app allows users to interactively . You can access the live app here:
- [Shiny App Link](https://yxu647.shinyapps.io/shiny/)
