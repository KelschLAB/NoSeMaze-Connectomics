# panel_D_mricrogl.py
# Jonathan Reinwald
#
# MRIcroGL rendering script for Figure 2D.
#
# Expected repository structure:
#
# NoSeMaze-Connectomics/
# ├── figures/main/Figure_2/
# │   └── panel_D_mricrogl.py
# ├── data/reference/templates/
# │   └── DL_template_original_inPax_brain.nii.gz
# ├── data/processed/fMRI/Figure_2D/
# │   ├── activation*.nii
# │   └── deactivation*.nii
# └── results/main/Figure_2/Figure_2D/

import gl
import os
import sys


# -------------------------------------------------------------------------
# Repository location
#
# MRIcroGL's internal Python interpreter cannot reliably determine the
# location of the currently opened script. Therefore, users must adapt
# only this path after downloading or cloning the repository.
# -------------------------------------------------------------------------

repo_root = (
    r"C:\Users\jonathan.reinwald\Dropbox\ICON_Autonomouse\reappraisal"
    r"\manuscript\NoSeMaze-Connectomics"
)


# -------------------------------------------------------------------------
# Define repository-relative paths
# -------------------------------------------------------------------------

template_file = os.path.join(
    repo_root,
    "data",
    "reference",
    "templates",
    "DL_template_original_inPax_brain.nii.gz"
)

overlay_directory = os.path.join(
    repo_root,
    "data",
    "processed",
    "fMRI",
    "Figure_2D"
)

output_directory = os.path.join(
    repo_root,
    "results",
    "main",
    "Figure_2",
    "Figure_2D"
)


# -------------------------------------------------------------------------
# Check repository folders and input files
# -------------------------------------------------------------------------

if not os.path.isdir(repo_root):
    raise RuntimeError(
        "Repository folder not found:\n"
        + repo_root
        + "\n\nEdit repo_root near the beginning of the script."
    )

if not os.path.isfile(template_file):
    raise FileNotFoundError(
        "Template image not found:\n"
        + template_file
        + "\n\nExpected repository location:\n"
        + "data/reference/templates/"
        + "DL_template_original_inPax_brain.nii.gz"
    )

if not os.path.isdir(overlay_directory):
    raise FileNotFoundError(
        "Overlay directory not found:\n"
        + overlay_directory
        + "\n\nExpected repository location:\n"
        + "data/processed/fMRI/Figure_2D/"
    )

if not os.path.isdir(output_directory):
    os.makedirs(output_directory)


# -------------------------------------------------------------------------
# Helper functions
# -------------------------------------------------------------------------

def is_nifti_file(filename):
    """Return True for .nii and .nii.gz files."""

    lower_filename = filename.lower()

    return (
        lower_filename.endswith(".nii")
        or lower_filename.endswith(".nii.gz")
    )


def remove_nifti_extension(filename):
    """Remove .nii or .nii.gz from a filename."""

    lower_filename = filename.lower()

    if lower_filename.endswith(".nii.gz"):
        return filename[:-7]

    if lower_filename.endswith(".nii"):
        return filename[:-4]

    return os.path.splitext(filename)[0]


def find_activation_files(search_directory):
    """Find all activation NIfTI files recursively."""

    files = []

    for directory_path, directory_names, filenames in os.walk(
        search_directory
    ):

        directory_names.sort()

        for filename in sorted(filenames):

            if (
                is_nifti_file(filename)
                and filename.lower().startswith("activation")
            ):
                files.append(
                    os.path.join(
                        directory_path,
                        filename
                    )
                )

    return files


# -------------------------------------------------------------------------
# Print software and path information
# -------------------------------------------------------------------------

print("Python version:")
print(sys.version)

print("MRIcroGL version:")
print(gl.version())

print("Repository root:")
print(repo_root)

print("Template:")
print(template_file)

print("Overlay directory:")
print(overlay_directory)

print("Output directory:")
print(output_directory)


# -------------------------------------------------------------------------
# Locate activation files
# -------------------------------------------------------------------------

activation_files = find_activation_files(
    overlay_directory
)

if len(activation_files) == 0:
    raise RuntimeError(
        "No activation NIfTI files were found in:\n"
        + overlay_directory
        + "\n\nExpected filenames beginning with 'activation'."
    )

print(
    "Number of activation maps found: "
    + str(len(activation_files))
)


# -------------------------------------------------------------------------
# Configure MRIcroGL
# -------------------------------------------------------------------------

gl.resetdefaults()

# White colorbar background
gl.colorbarcolor(
    255,
    255,
    255,
    255
)

# Load anatomical template
gl.loadimage(
    template_file
)

# Remove haze:
# blur edges, retain a single object, and apply threshold
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)
gl.extract(1, 1, 5)

# Template intensity range
gl.minmax(
    0,
    0,
    1200000
)

# White background
gl.backcolor(
    255,
    255,
    255
)

# Mosaic definition
#
# C = coronal slices
# S = sagittal slices
# A = axial slices
# X = reference lines
# R = rendered reference image
gl.mosaic(
    "C 30 25 20 15 -8 S X R 0; "
    "A -12 -25 -28 -31 -34 C X R 0; "
    "Z 12 16 20 24 A X R 0"
)


# -------------------------------------------------------------------------
# Render each activation/deactivation pair
# -------------------------------------------------------------------------

for activation_file in activation_files:

    activation_folder = os.path.dirname(
        activation_file
    )

    activation_filename = os.path.basename(
        activation_file
    )

    # Original naming convention:
    #
    # activationExample.nii
    # deactivationExample.nii
    deactivation_filename = (
        "de" + activation_filename
    )

    deactivation_file = os.path.join(
        activation_folder,
        deactivation_filename
    )

    if not os.path.isfile(deactivation_file):
        raise FileNotFoundError(
            "Matching deactivation map not found.\n\n"
            "Activation map:\n"
            + activation_file
            + "\n\nExpected deactivation map:\n"
            + deactivation_file
        )

    print("")
    print("Rendering activation map:")
    print(activation_file)

    print("Rendering deactivation map:")
    print(deactivation_file)

    # Remove overlays from the previous iteration
    gl.overlaycloseall()

    # ---------------------------------------------------------------------
    # Load overlays
    # ---------------------------------------------------------------------

    gl.overlayload(
        activation_file
    )

    gl.overlayload(
        deactivation_file
    )

    gl.overlaymaskwithbackground(1)

    # ---------------------------------------------------------------------
    # Overlay 1: activation
    # ---------------------------------------------------------------------

    gl.minmax(
        1,
        3,
        15
    )

    gl.opacity(
        1,
        100
    )

    gl.colorname(
        1,
        "8redyell"
    )

    # ---------------------------------------------------------------------
    # Overlay 2: deactivation
    # ---------------------------------------------------------------------

    gl.minmax(
        2,
        3,
        15
    )

    gl.opacity(
        2,
        100
    )

    gl.colorname(
        2,
        "6bluegrn"
    )

    # ---------------------------------------------------------------------
    # Shared display settings
    # ---------------------------------------------------------------------

    gl.colorbarposition(2)

    # Custom MRIcroGL shader
    gl.shadername(
        "MatcapMix_JR"
    )

    # ---------------------------------------------------------------------
    # Save rendered mosaic
    # ---------------------------------------------------------------------

    activation_base_name = remove_nifti_extension(
        activation_filename
    )

    output_file = os.path.join(
        output_directory,
        "mosaic_" + activation_base_name
    )

    gl.savebmp(
        output_file
    )

    print("Saved mosaic:")
    print(output_file)


# -------------------------------------------------------------------------
# Clean up
# -------------------------------------------------------------------------

gl.overlaycloseall()

print("")
print("Figure 2D rendering completed.")
print("Outputs saved to:")
print(output_directory)

