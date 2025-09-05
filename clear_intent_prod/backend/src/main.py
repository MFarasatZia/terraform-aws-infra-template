import boto3
import psycopg2
import os


def reset(event, context):
    host = os.environ['DB_HOST']
    username = os.environ['DB_USERNAME']
    password = os.environ['DB_PASSWORD']
    database = os.environ['DB_NAME']  # name of the database to drop
    mode = os.environ.get('MODE', 'prod')

    if mode != 'dev':
        return

    conn = psycopg2.connect(host=host, database="postgres", user=username, password=password)
    conn.autocommit = True

    with conn.cursor() as cur:
        # Drop the database
        cur.execute(f"DROP DATABASE IF EXISTS {database} WITH (FORCE);")
        
        # Create a new database
        cur.execute(f"CREATE DATABASE {database};")

    conn.close()

    return {
        'statusCode': 200,
        'body': f"Database {database} has been cleared successfully"
    }


def launch_pipeline(event, context):
    mode = os.environ.get('MODE', 'prod')

    if mode != 'dev':
        return

    pipeline_id = os.environ['PIPELINE_ID']

    cp_client = boto3.client('codepipeline')
    cp_client.start_pipeline_execution(name=pipeline_id)

    return {
        'statusCode': 200,
        'body': f"Pipeline {pipeline_id} launched"
    }
