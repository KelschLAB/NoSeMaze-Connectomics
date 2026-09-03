# panel_C_mricrogl.py
#
# MRIcroGL script for Figure 6C.
#
# Displays the fraction-of-losses-related activation map on the
# high-resolution Paxinos-space anatomical template.
#
# IMPORTANT:
# MRIcroGL's internal Python environment cannot reliably infer the
# repository root from this script's own location. Therefore, edit the
# single repo_root line below if the repository is moved.

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
    'Figure_6',
    'Figure_6C'
)

output_dir = os.path.join(
    repo_root,
    'results',
    'main',
    'Figure_6',
    'Figure_6C'
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
        'Figure 6C input directory not found:\n' + input_dir
    )

overlay_files = sorted([
    filename
    for filename in os.listdir(input_dir)
    if filename.startswith('activation')
    and filename.endswith('T01.nii')
])

if len(overlay_files) == 0:
    raise FileNotFoundError(
        'No file matching activation*T01.nii found in:\n' + input_dir
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

# Remove haze / extract brain: retained from original script.
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)

# High-resolution anatomical template intensity range
gl.minmax(0, 0, 1200000)

# Mosaic retained from original script
gl.mosaic('C -27 -31 -37 S X R 0; A -32 -35 -37')

# -------------------------------------------------------------------------
# Overlay loop
# -------------------------------------------------------------------------

for filename in overlay_files:

    overlay_file = os.path.join(input_dir, filename)

    print('Rendering:')
    print(overlay_file)

    # Clear the previous statistical map before loading the next one.
    # This prevents overlays from accumulating when multiple matching
    # NIfTI files are present.
    gl.overlaycloseall()

    gl.overlayload(overlay_file)
    gl.overlaymaskwithbackground(1)

    gl.minmax(1, 2, 5)
    gl.opacity(1, 100)
    gl.colorname(1, '1RedJR')
    gl.colorbarposition(2)
    gl.shadername('MatcapMix_JR')

    stem = filename[:-4]  # remove ".nii"

    output_file = os.path.join(
        output_dir,
        'render_' + stem
    )

    gl.savebmp(output_file)

    print('Saved:')
    print(output_file)

print('Figure 6C rendering complete.')

