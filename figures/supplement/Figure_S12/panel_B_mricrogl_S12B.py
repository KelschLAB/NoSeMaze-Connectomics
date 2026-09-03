# panel_B_mricrogl.py
#
# MRIcroGL script for Supplementary Figure 12B.
#
# Displays the David's score z-scored deactivation map on the
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
# │   └── panel_B_mricrogl.py
# │
# ├── data/reference/templates/
# │   └── DL_template_original_inPax_brain.nii.gz
# │
# ├── data/processed/fMRI/Figure_S12/Figure_S12B/
# │   └── deactivation*T01.nii
# │
# └── results/supplement/Figure_S12/Figure_S12B/
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
    'DL_template_original_inPax_brain.nii.gz'
)

input_dir = os.path.join(
    repo_root,
    'data',
    'processed',
    'fMRI',
    'Figure_S12',
    'Figure_S12B'
)

output_dir = os.path.join(
    repo_root,
    'results',
    'supplement',
    'Figure_S12',
    'Figure_S12B'
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
        'Supplementary Figure 12B input directory not found:\n' + input_dir
    )

overlay_files = sorted([
    filename
    for filename in os.listdir(input_dir)
    if filename.startswith('deactivation')
    and filename.endswith('T01.nii')
])

if len(overlay_files) == 0:
    raise FileNotFoundError(
        'No file matching deactivation*T01.nii found in:\n' + input_dir
    )

print('Template:')
print(template_file)

print('Overlay files:')
for filename in overlay_files:
    print(os.path.join(input_dir, filename))

# -------------------------------------------------------------------------
# Anatomical template
# -------------------------------------------------------------------------

gl.colorbarcolor(255, 255, 255, 255)
gl.backcolor(255, 255, 255)

gl.loadimage(template_file)

# Remove haze / extract brain: retained exactly from Figure S12A.
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)

# High-resolution anatomical template intensity range
gl.minmax(0, 0, 1200000)

# Mosaic matched to Figure S12A
gl.mosaic('C -27 -31 -37 S X R 0; A -32 -35 -37')

# -------------------------------------------------------------------------
# Overlay loop
# -------------------------------------------------------------------------

for filename in overlay_files:

    overlay_file = os.path.join(input_dir, filename)

    print('Rendering:')
    print(overlay_file)

    gl.overlaycloseall()

    gl.overlayload(overlay_file)
    gl.overlaymaskwithbackground(1)

    gl.minmax(1, 2, 5)
    gl.opacity(1, 100)

    # Map definition retained from the original Figure S12B script
    gl.colorname(1, '1LilaJR')
    gl.colorbarposition(2)

    # Shader matched to Figure S12A
    gl.shadername('MatcapMix_JR')

    stem = filename[:-4]  # remove ".nii"

    output_file = os.path.join(
        output_dir,
        'render_' + stem
    )

    gl.savebmp(output_file)

    print('Saved:')
    print(output_file)

# Keep final overlay loaded
# gl.overlaycloseall()

print('Supplementary Figure 12B rendering complete.')

