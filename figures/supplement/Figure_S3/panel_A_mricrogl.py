# panel_A_mricrogl.py
# Jonathan Reinwald
#
# MRIcroGL rendering script for Supplementary Figure S3A.
#
# Figure S3A:
#   odor-evoked activation map from the separate HRF-estimation cohort.
#
# Input:
#   data/processed/fMRI/Figure_S3/Figure_S3A/
#       activation_OdorCombined_T001.nii
#
# Anatomical template:
#   data/reference/templates/
#       DL_template_original_inPax_brain.nii
#
# Output:
#   results/supplement/Figure_S3/Figure_S3A/
#
# IMPORTANT:
# MRIcroGL's embedded Python environment cannot reliably determine this
# script's location. Edit only the repo_root line below if the repository
# is moved.
#
# Required MRIcroGL resource:
#   shader: MatcapMix_JR
#
# -------------------------------------------------------------------------

import gl
import os
import sys

print(sys.version)
print(gl.version())

gl.resetdefaults()

# =========================================================================
# EDIT ONLY THIS LINE IF THE REPOSITORY MOVES
# =========================================================================

repo_root = r'C:\Users\jonathan.reinwald\Dropbox\ICON_Autonomouse\reappraisal\manuscript\NoSeMaze-Connectomics'

# =========================================================================
# Repository-relative paths
# =========================================================================

template_file = os.path.join(
    repo_root,
    'data',
    'reference',
    'templates',
    'DL_template_original_inPax_brain.nii'
)

overlay_file = os.path.join(
    repo_root,
    'data',
    'processed',
    'fMRI',
    'Figure_S3',
    'Figure_S3A',
    'activation_OdorCombined_T001.nii'
)

output_dir = os.path.join(
    repo_root,
    'results',
    'supplement',
    'Figure_S3',
    'Figure_S3A'
)

output_file = os.path.join(
    output_dir,
    'Figure_S3A_activation_OdorCombined_T001'
)

# =========================================================================
# Input checks / output directory
# =========================================================================

if not os.path.isfile(template_file):
    raise FileNotFoundError(
        'Template file not found:\n' + template_file
    )

if not os.path.isfile(overlay_file):
    raise FileNotFoundError(
        'Figure S3A overlay file not found:\n' + overlay_file
    )

if not os.path.isdir(output_dir):
    os.makedirs(output_dir)

print('Template:')
print(template_file)

print('Overlay:')
print(overlay_file)

# =========================================================================
# Anatomical template
# =========================================================================

gl.colorbarcolor(255, 255, 255, 255)
gl.backcolor(255, 255, 255)

gl.loadimage(template_file)

# Remove haze / isolate brain, retained from the historical script.
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)

# High-resolution Paxinos template intensity range.
gl.minmax(0, 0, 1200000)

# Historical Figure S3A layout:
#   coronal   x = 23
#   axial     z = -24
#   sagittal  y = 0
gl.mosaic('X C23 X R 0; A -24 R 0; S 0 R 0')

# =========================================================================
# Statistical overlay
# =========================================================================

gl.overlaycloseall()

gl.overlayload(overlay_file)
gl.overlaymaskwithbackground(1)

gl.minmax(1, 3, 12)
gl.opacity(1, 100)
gl.colorname(1, '8redyell')

gl.colorbarposition(2)
gl.shadername('MatcapMix_JR')

# =========================================================================
# Save
# =========================================================================

gl.savebmp(output_file)

gl.overlaycloseall()

print('Completed Figure S3A.')
print('Output:')
print(output_file)
