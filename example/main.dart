// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_ecs/otel_aws_ecs.dart';

/// Traces AWS ECS calls with OpenTelemetry.
///
/// `otel_aws_ecs` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each AWS ECS call in
/// [tracedAwsEcs]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-ecs-example');

  // Wraps an AWS ECS call in a CLIENT span.
  final awsEcsId = await tracedAwsEcs<String>(
    operation: 'exec.session.start',
    invoke: () async {
      // Make the AWS ECS call here, then report what it returned.
      const id = 'aws_ecs_8f3a2c';
      return const AwsEcsCallResult(
          value: id,
          result: AwsEcsResult(
              region: 'us-east-1',
              cluster: 'example',
              launchType: 'EC2',
              capacityProvider: 'example',
              taskDefinition: 'example',
              taskDefinitionRevision: 1,
              taskArn: 'example',
              containerArn: 'example',
              containerName: 'example',
              image: 'example',
              cpuUnits: 1,
              memoryMib: 1,
              gpuCount: 3,
              runtimePlatform: 'LINUX_X86_64',
              networkMode: 'bridge',
              serviceName: 'example',
              serviceDeploymentId: 'servicedeployment_8f3a2c',
              desiredCount: 3,
              runningCount: 3,
              pendingCount: 3,
              healthStatus: 'HEALTHY',
              lastStatus: 'PROVISIONING',
              stopReason: 'EssentialContainerExited',
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 200));
    },
  );
  OTelLog.info('tracedAwsEcs exec.session.start returned $awsEcsId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsEcsInstrumentationAsync.
  await runWithoutAwsEcsInstrumentationAsync(
    () => tracedAwsEcs<String>(
      operation: 'exec.session.start',
      invoke: () async {
        const id = 'aws_ecs_8f3a2c';
        return const AwsEcsCallResult(
            value: id,
            result: AwsEcsResult(
                region: 'us-east-1',
                cluster: 'example',
                launchType: 'EC2',
                capacityProvider: 'example',
                taskDefinition: 'example',
                taskDefinitionRevision: 1,
                taskArn: 'example',
                containerArn: 'example',
                containerName: 'example',
                image: 'example',
                cpuUnits: 1,
                memoryMib: 1,
                gpuCount: 3,
                runtimePlatform: 'LINUX_X86_64',
                networkMode: 'bridge',
                serviceName: 'example',
                serviceDeploymentId: 'servicedeployment_8f3a2c',
                desiredCount: 3,
                runningCount: 3,
                pendingCount: 3,
                healthStatus: 'HEALTHY',
                lastStatus: 'PROVISIONING',
                stopReason: 'EssentialContainerExited',
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 200));
      },
    ),
  );

  await OTel.shutdown();
}
