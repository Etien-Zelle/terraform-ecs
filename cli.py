#!/usr/bin/env python
#This script specifies two cli
#one command lists content from s3
#one command lists ecs task definition version

import boto3
import click

@click.group()
def cli():
    pass

@cli.command()
def list_s3_files():
    s3 = boto3.client('s3')
    response = s3.list_objects(Bucket='et-bucket')
    for content in response.get('Contents'):
        print(content.get('Key'))

@cli.command()
def list_ecs_task_definition_versions():
    ecs = boto3.client('ecs')
    response = ecs.list_task_definition_families(familyPrefix='nginx')
    for task_definition in response['families']:
        versions = ecs.list_task_definitions(familyPrefix=task_definition)
        for version in versions['taskDefinitionArns']:
            print(version)

if __name__ == '__main__':
    cli()
