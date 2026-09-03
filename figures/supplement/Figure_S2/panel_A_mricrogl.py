# panel_A_mricrogl.py
# Jonathan Reinwald
#
# MRIcroGL rendering script for Supplementary Figure S2A.
#
# Figure S2A:
#   No-puff control cohort, proximal-CR (TPnoPuff) PRE block
#   (trials 11-40), showing activation and deactivation maps.
#
# The script searches:
#
#   data/processed/fMRI/Figure_S2/Figure_S2A/
#
# for:
#
#   activation*.nii
#
# and expects the corresponding deactivation file to be:
#
#   de + activation filename
#
# Example:
#
#   activation_example.nii
#   deactivation_example.nii
#
# IMPORTANT:
# MRIcroGL's internal Python environment cannot reliably determine this
# script's location. Edit the single repo_root line below when the
# repository is moved.
#
# Required MRIcroGL resource:
#   shader: MatcapMix_JR
#
# Output:
#   results/supplement/Figure_S2/Figure_S2A/
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

input_dir = os.path.join(
    repo_root,
    'data',
    'processed',
    'fMRI',
    'Figure_S2',
    'Figure_S2A'
)

output_dir = os.path.join(
    repo_root,
    'results',
    'supplement',
    'Figure_S2',
    'Figure_S2A'
)

# =========================================================================
# Input / output checks
# =========================================================================

if not os.path.isfile(template_file):
    raise FileNotFoundError(
        'Template file not found:\n' + template_file
    )

if not os.path.isdir(input_dir):
    raise FileNotFoundError(
        'Figure S2A input directory not found:\n' + input_dir
    )

if not os.path.isdir(output_dir):
    os.makedirs(output_dir)

activation_files = sorted([
    filename
    for filename in os.listdir(input_dir)
    if filename.startswith('activation')
    and filename.endswith('.nii')
])

if len(activation_files) == 0:
    raise FileNotFoundError(
        'No activation*.nii files found in:\n' + input_dir
    )

print('Figure S2A activation maps:')
for filename in activation_files:
    print('  ' + filename)

# =========================================================================
# Anatomical template
# =========================================================================

gl.colorbarcolor(255, 255, 255, 255)
gl.backcolor(255, 255, 255)

gl.loadimage(template_file)

# Remove haze / isolate brain.
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)

# High-resolution Paxinos template intensity range.
gl.minmax(0, 0, 1200000)

# Historical Figure S2A mosaic.
gl.mosaic(
    'C 30 25 20 15 -8 S X R 0; '
    'A -12 -25 -28 -31 -34 C X R 0; '
    'Z 12 16 20 24 A X R 0'
)

# =========================================================================
# Activation / deactivation map pairs
# =========================================================================

for activation_filename in activation_files:

    activation_file = os.path.join(
        input_dir,
        activation_filename
    )

    deactivation_filename = 'de' + activation_filename

    deactivation_file = os.path.join(
        input_dir,
        deactivation_filename
    )

    if not os.path.isfile(deactivation_file):
        raise FileNotFoundError(
            'Matching deactivation map not found for:\n'
            + activation_filename
            + '\n\nExpected:\n'
            + deactivation_file
        )

    print('')
    print('Processing:')
    print('  activation:   ' + activation_file)
    print('  deactivation: ' + deactivation_file)

    # Clear previous overlays while retaining the template and view.
    gl.overlaycloseall()

    gl.overlayload(activation_file)
    gl.overlayload(deactivation_file)

    gl.overlaymaskwithbackground(1)

    # Overlay 1: activation.
    gl.minmax(1, 3, 15)
    gl.opacity(1, 100)
    gl.colorname(1, '8redyell')

    # Overlay 2: deactivation.
    gl.minmax(2, 3, 15)
    gl.opacity(2, 100)
    gl.colorname(2, '6bluegrn')

    gl.colorbarposition(2)
    gl.shadername('MatcapMix_JR')

    base_name = os.path.splitext(
        activation_filename
    )[0]

    output_file = os.path.join(
        output_dir,
        'Figure_S2A_mosaic_' + base_name
    )

    gl.savebmp(output_file)

    print('Saved:')
    print('  ' + output_file)

    gl.overlaycloseall()

print('')
print('Completed Figure S2A.')
print('Outputs saved to:')
print(output_dir)
