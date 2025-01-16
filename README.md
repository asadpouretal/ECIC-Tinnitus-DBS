# ICx-DBS-Tinnitus

This repository contains MATLAB scripts and data analysis tools used in the study **"Modulation of Auditory Cortex Activity in Salicylate-Induced Tinnitus Rats via Deep Brain Stimulation of the Inferior Colliculus"**. It includes code for spike detection, firing rate analysis, and inter-spike interval (ISI) comparisons.

## Contents

### 1. Scripts
- **`Run.m`**: Main script to initiate the analysis pipeline.
- **`analyze_spike_data`**: Processes spike train data and extracts firing rate information.
- **`plot_average_firing_rate_group`**: Plots the average firing rate for control and tinnitus groups (generates Figure 4A).
- **`compare_isi_histograms_group`**: Compares and plots ISI histograms for control and tinnitus groups before and after stimulation (generates Figures 4B and 4C).

### 2. Data
- Firing rate data for control and tinnitus groups, organized into folders for conditions (`Before stimulation` and `After stimulation`).
- ISI data, derived from spike trains.
- **Sample data**: Available at [Google Drive](https://drive.google.com/drive/folders/1szNyxYHtiI4j4M5UCZQhQBxxYyPoGAHg?usp=sharing).

### 3. Outputs
- **Figure 4A**: Average firing rate plots.
- **Figure 4B-C**: ISI histograms comparing control and tinnitus groups.

## Usage

### Prerequisites
- MATLAB installed with required toolboxes (e.g., Signal Processing Toolbox).
- Ensure paths to necessary toolboxes and data folders are set correctly in `Run.m`.

### Steps to Run
1. **Clone the repository**:
   ```bash
   git clone https://github.com/asadpouretal/ICx-Tinnitus-DBS.git
   ```
2. **Open MATLAB** and navigate to the repository directory.
3. **Run the main script**:
   ```matlab
   Run
   ```
4. Follow the prompts for input parameters and data selection.

## Directory Structure
The repository assumes the following structure for input data:
```
parent_folder/
  ├── Control/
  │   ├── Before stimulation/
  │   └── After stimulation/
  └── Tinnitus/
      ├── Before stimulation/
      └── After stimulation/
```
Ensure that firing rate and ISI results are organized into these folders.

## Licensing

### Code
The MATLAB code in this repository is licensed under the **MIT License**:
- You are free to use, modify, and distribute the code, provided proper attribution is given.
- See the [LICENSE](LICENSE) file for full details.

### Data
The data provided in this repository is licensed under the **Creative Commons Attribution 4.0 International (CC BY 4.0)** license:
- You are free to share and adapt the data, provided proper credit is given.
- Note: The full analyzed data and raw spike data are not included in this repository but are available upon reasonable request from the corresponding authors.
- See the [CC BY 4.0 License](https://creativecommons.org/licenses/by/4.0/) for more information.

## Citation
If you use this repository, please cite the associated manuscript:
```
Zeinab Akbarnejad et al., Modulation of Auditory Cortex Activity in Salicylate-Induced Tinnitus Rats via Deep Brain Stimulation of the Inferior Colliculus. CNS Neuroscience & Therapeutics.
```

## Contact
For questions or issues, please contact:
- Abdoreza Asadpour: [a.asadpour@sussex.ac.uk](mailto:a.asadpour@sussex.ac.uk)
- Alimohamad Asghari: [ashghari.am@iums.ac.ir](mailto:ashghari.am@iums.ac.ir)
