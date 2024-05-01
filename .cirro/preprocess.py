#!/usr/bin/env python3

from cirro.helpers.preprocess_dataset import PreprocessDataset
import pandas as pd

def setup_input_parameters(ds: PreprocessDataset):

    # If the user did not select a custom Cell Markers DB CSV, use the default
    if ds.params.get("annotation_db") is None:
        ds.add_param(
            "annotation_db",
            "./assets/cell_markers_database.csv"
        )

    # If the user did not select a custom Meta-Program CSV, use the default
    if ds.params.get("cell_mask") is None:
        ds.add_param(
            "cell_mask",
            "./assets/meta_programs_database.csv"
        )


if __name__ == "__main__":

    ds = PreprocessDataset.from_running()

    setup_input_parameters(ds)
    
    # log
    ds.logger.info(ds.params)