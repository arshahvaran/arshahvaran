import os
import pandas as pd

# 1. Define folder paths
base_dir = r"E:\publications\noori_4\data\process_3_unzipped"
output_dir = r"E:\publications\noori_4\data\process_4_cleaned"

folders = {
    "chla_mean": os.path.join(base_dir, "chla_mean"),
    "lake_surface_water_temperature": os.path.join(base_dir, "lake_surface_water_temperature"),
    "turbidity_mean": os.path.join(base_dir, "turbidity_mean")
}

# Define the exact 15 row headers in the requested order
stats_list = ['min', 'max', 'mean', 'sd', 'count']
param_order = ["chla_mean", "lake_surface_water_temperature", "turbidity_mean"]
expected_rows = [f"{p}_{s}" for p in param_order for s in stats_list]

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# 2. Identify the UNION of all unique lakes across all three folders
all_unique_files = set()
for folder in folders.values():
    files = {f for f in os.listdir(folder) if f.endswith('.csv')}
    all_unique_files.update(files)

all_unique_files = sorted(list(all_unique_files))
print(f"Found {len(all_unique_files)} unique lakes in total. Processing...")

# 3. Process each lake
for filename in all_unique_files:
    dataframes = []
    
    for param_name in param_order:
        file_path = os.path.join(folders[param_name], filename)
        
        if os.path.exists(file_path):
            # Read existing data
            df = pd.read_csv(file_path, index_col='Statistic')
            # Prefix index: 'min' -> 'chla_mean_min'
            df.index = [f"{param_name}_{idx}" for idx in df.index]
            dataframes.append(df)
        else:
            # If lake is missing this parameter, create an empty placeholder with correct rows
            placeholder_idx = [f"{param_name}_{s}" for s in stats_list]
            df_empty = pd.DataFrame(index=placeholder_idx)
            dataframes.append(df_empty)
    
    # 4. Merge all dataframes (aligns by dates/columns)
    combined_df = pd.concat(dataframes, axis=0, sort=False)
    
    # Ensure the 15 rows are in the exact order requested
    combined_df = combined_df.reindex(expected_rows)
    
    # 5. Chronological sorting of date columns
    if not combined_df.columns.empty:
        # Convert column names to datetime for proper sorting
        date_cols = pd.to_datetime(combined_df.columns)
        combined_df.columns = date_cols
        
        # Sort columns and convert back to YYYY-MM-DD
        combined_df = combined_df.reindex(sorted(combined_df.columns), axis=1)
        combined_df.columns = combined_df.columns.strftime('%Y-%m-%d')
    
    # 6. Save the cleaned file
    output_path = os.path.join(output_dir, filename)
    combined_df.to_csv(output_path, index_label='Statistic')

print(f"Task completed. {len(all_unique_files)} files processed and saved to {output_dir}")