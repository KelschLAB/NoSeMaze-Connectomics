# panel_D_mricrogl.py
#
# MRIcroGL script for Supplementary Figure 12D.
#
# Displays the TFCE-confirmed rank-related map on the
# high-resolution Paxinos-space anatomical template.
#
# IMPORTANT:
# MRIcroGL's internal Python environment cannot reliably infer the
# repository root from this script's own location. Therefore, edit the
# single repo_root line below if the repository is moved.
#
# Expected repository structure:
#
# NoSeMaze-Connectomics/
# ├── figures/supplement/Figure_S12/
# │   └── panel_D_mricrogl.py
# │
# ├── data/reference/templates/
# │   └── DL_template_original_inPax_brain.nii
# │
# ├── data/processed/fMRI/Figure_6/Figure_6A/
# │   └── TFCE_rankPos_FWE_05.nii
# │
# └── results/supplement/Figure_S12/Figure_S12D/
#
# Custom MRIcroGL resources required:
#   - color map: 1LilaJR
#   - shader:    MatcapMix_JR
#
# -------------------------------------------------------------------------

import gl
import sys
import os

print(sys.version)
print(gl.version())

gl.resetdefaults()

# -------------------------------------------------------------------------
# EDIT ONLY THIS LINE IF THE REPOSITORY MOVES
# -------------------------------------------------------------------------

repo_root = r'C:\Users\jonathan.reinwald\Dropbox\ICON_Autonomouse\reappraisal\manuscript\NoSeMaze-Connectomics'

# -------------------------------------------------------------------------
# Repository-relative paths
# -------------------------------------------------------------------------

template_file = os.path.join(
    repo_root,
    'data',
    'reference',
    'templates',
    'DL_template_original_inPax_brain.nii'
)

# Reuse the Figure 6A source-data directory
input_dir = os.path.join(
    repo_root,
    'data',
    'processed',
    'fMRI',
    'Figure_6',
    'Figure_6A'
)

output_dir = os.path.join(
    repo_root,
    'results',
    'supplement',
    'Figure_S12',
    'Figure_S12D'
)

if not os.path.isdir(output_dir):
    os.makedirs(output_dir)

# -------------------------------------------------------------------------
# Input checks
# -------------------------------------------------------------------------

if not os.path.isfile(template_file):
    raise FileNotFoundError(
        'Template not found:\n' + template_file
    )

if not os.path.isdir(input_dir):
    raise FileNotFoundError(
        'Figure 6A input directory not found:\n' + input_dir
    )

# Select exactly the TFCE-positive-rank FWE-corrected map.
overlay_filename = 'TFCE_rankPos_FWE_05.nii'
overlay_file = os.path.join(input_dir, overlay_filename)

if not os.path.isfile(overlay_file):
    raise FileNotFoundError(
        'Required overlay not found:\n' + overlay_file
    )

print('Template:')
print(template_file)

print('TFCE overlay:')
print(overlay_file)

# -------------------------------------------------------------------------
# Anatomical template
# -------------------------------------------------------------------------

gl.colorbarcolor(255, 255, 255, 255)
gl.backcolor(255, 255, 255)

gl.loadimage(template_file)

# Remove haze / extract brain
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)

# High-resolution anatomical template intensity range
gl.minmax(0, 0, 1200000)

# Same mosaic as Figure S12C
gl.mosaic('C -27 -31 -37 S X R 0; A -32 -35 -37')

# -------------------------------------------------------------------------
# Overlay
# -------------------------------------------------------------------------

print('Rendering:')
print(overlay_file)

gl.overlaycloseall()

gl.overlayload(overlay_file)
gl.overlaymaskwithbackground(1)

# Display range requested for Figure S12D
gl.minmax(1, 350, 550)
gl.opacity(1, 100)
gl.colorname(1, '1LilaJR')
gl.colorbarposition(2)
gl.shadername('MatcapMix_JR')

stem = overlay_filename[:-4]  # remove ".nii"

output_file = os.path.join(
    output_dir,
    'render_' + stem
)

gl.savebmp(output_file)

print('Saved:')
print(output_file)

# Keep final overlay loaded
# gl.overlaycloseall()

print('Supplementary Figure 12D rendering complete.')
