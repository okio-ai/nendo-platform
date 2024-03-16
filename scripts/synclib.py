#!/usr/bin/env python3
import argparse
import os
import subprocess

def backup(library_path, gcs_storage_path):
    # Dump PostgreSQL database
    target_path = os.path.join(library_path, "nendo.sql")
    dump_command = f"docker exec -it nendo-postgres pg_dump -U nendo -d nendo > {target_path}"
    try:
        print(f"Executing: {dump_command}")
        subprocess.run(dump_command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing database dump: {e}")
        return

    # Sync to GCS
    sync_command = f"gsutil -m rsync -d -r {library_path} {gcs_storage_path}"
    try:
        print(f"Executing: {sync_command}")
        subprocess.run(sync_command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error syncing to GCS: {e}")

def restore(library_path, gcs_storage_path):
    # Copy the SQL file into the Docker container
    target_path = os.path.join(library_path, "nendo.sql")
    copy_command = f"docker cp {target_path} nendo-postgres:/root/nendo.sql"
    try:
        print(f"Executing: {copy_command}")
        subprocess.run(copy_command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error copying SQL file into Docker container: {e}")
        return

    # Import the SQL file into the PostgreSQL database
    import_command = "docker exec -it nendo-postgres psql -U nendo -d nendo -f /root/nendo.sql"
    try:
        print(f"Executing: {import_command}")
        subprocess.run(import_command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error importing SQL file into database: {e}")
        return

    # Sync from GCS
    sync_command = f"gsutil -m rsync -d -r {gcs_storage_path} {library_path}"
    try:
        print(f"Executing: {sync_command}")
        subprocess.run(sync_command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error syncing from GCS: {e}")
        return

def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='Manage PostgreSQL database backup and restore to/from GCS.')
    parser.add_argument('--library-path', required=True, help='Path to local library directory')
    parser.add_argument('--gcs-storage-path', required=True, help='Path to directory in GCS bucket')
    parser.add_argument('--mode', choices=['backup', 'restore'], required=True, help='Operation mode: backup or restore')
    args = parser.parse_args()

    if args.mode == 'backup':
        backup(args.library_path, args.gcs_storage_path)
    elif args.mode == 'restore':
        restore(args.library_path, args.gcs_storage_path)

if __name__ == '__main__':
    main()
