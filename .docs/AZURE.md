# Using Azure Pipelines with C++ Projects

This guide describes how to use Azure Pipelines to build and test C++ projects.
It uses a pipeline `azure-pipeline.yml' and a template `build-template.yml' for a comprehensive CI/CD pipeline.

## Prerequisites

- Access to an Azure DevOps service or server.
- Follow the [documentation](../README.md) starting with the [initial general configuration](../README.md#initial-general-configuration).

## Setting Up Your Pipeline

1. Fork the repository in GitHub or import it into Azure DevOps.
2. In Azure DevOps, navigate to Pipelines and create a new pipeline.
3. Select GitHub or Azure Repos as the code source, and select your forked/imported repository.
4. When prompted for a configuration, select "Existing Azure Pipelines YAML file" and enter the path to `azure-pipeline.yml`.

## Configuring Build Parameters

Customize the build parameters in `azure-pipeline.yml` to meet the needs of your project.
- Choose between *Deploy*, which also publishes the build artifacts, or *Build* only.
- Enable or disable builds for Windows or Linux altogether. Note that if build is enabled but no matrix is generated, the pipeline will fail.

## Accessing private resources

In `build/build-template.yml' look for something like this:
```yaml
        ${{ if eq(parameters.agentType, 'containerized') }}:
          pool:
            vmImage: 'ubuntu-latest'
          container:
            image: $(container_image)
            options: -v /etc/localtime:/etc/localtime:ro
            # endpoint: Dockerhub # If you need access to a private container registry
        ${{ else }}:
          pool:
            vmImage: $(azure_vmImage)
```

### Using a Private Docker Registry

- Add a *Docker Registry* service connection where you can specify your credentials.
- Specify the new service connection in the container settings with the key `endpoint`, for example:
    ```yaml
            container:
                image: $(container_image)
                options: -v /etc/localtime:/etc/localtime:ro
                endpoint: myDockerhubAccount # If you need access to a private container registry
    ```

### Using self-hosted agents

Instead of specifying the `vmImage', specify the pool directly by name, e.g:
```yaml
        ${{ if eq(parameters.agentType, 'containerized') }}:
          pool: 'container-enabled-agents'
          container:
            image: $(container_image)
            options: -v /etc/localtime:/etc/localtime:ro
        ${{ else }}:
          pool: 'Win_vs2022_pool'
```

## Limitations

- Conan is not available on Microsoft-hosted agents, installation via `pip3` is done each time conan is needed and takes about 30 seconds.
- Caching of artifacts (such as conan dependencies) is not yet implemented.

## Customizing the build environment

- Modify the `build-template.yml` file to include any additional build steps or customizations required for your project.

For a detailed walkthrough and additional configuration options, refer to the [Azure Pipiles documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/?view=azure-devops).
