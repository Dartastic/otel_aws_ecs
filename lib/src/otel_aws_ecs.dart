// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_aws_ecs_suppression.dart';

const _tracerName = 'dartastic_otel_libs_aws_ecs';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class AwsEcsResult {
  const AwsEcsResult({
    this.region,
    this.cluster,
    this.launchType,
    this.capacityProvider,
    this.taskDefinition,
    this.taskDefinitionRevision,
    this.taskArn,
    this.containerArn,
    this.containerName,
    this.image,
    this.cpuUnits,
    this.memoryMib,
    this.gpuCount,
    this.runtimePlatform,
    this.networkMode,
    this.serviceName,
    this.serviceDeploymentId,
    this.desiredCount,
    this.runningCount,
    this.pendingCount,
    this.healthStatus,
    this.lastStatus,
    this.stopReason,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// AWS region.
  final String? region;

  final String? cluster;

  /// `EC2`, `FARGATE`, `EXTERNAL`.
  final String? launchType;

  final String? capacityProvider;

  final String? taskDefinition;
  final int? taskDefinitionRevision;

  final String? taskArn;
  final String? containerArn;
  final String? containerName;

  /// Container image (with tag/digest).
  final String? image;

  /// Reserved CPU units (1 vCPU = 1024 units).
  final int? cpuUnits;
  final int? memoryMib;
  final int? gpuCount;

  /// `LINUX_X86_64`, `LINUX_ARM64`, `WINDOWS_SERVER_2019_FULL`, ...
  final String? runtimePlatform;

  /// `bridge`, `host`, `awsvpc`, `none`.
  final String? networkMode;

  final String? serviceName;
  final String? serviceDeploymentId;

  final int? desiredCount;
  final int? runningCount;
  final int? pendingCount;

  /// `HEALTHY`, `UNHEALTHY`, `UNKNOWN`.
  final String? healthStatus;

  /// Task lifecycle: `PROVISIONING`, `PENDING`, `ACTIVATING`, `RUNNING`,
  /// `DEACTIVATING`, `STOPPING`, `DEPROVISIONING`, `STOPPED`.
  final String? lastStatus;

  /// Reason the task stopped (`EssentialContainerExited`,
  /// `OutOfMemoryError`, `TaskFailedToStart`, `UserInitiated`,
  /// `ServiceSchedulerInitiated`, `SpotInterruption`, ...).
  final String? stopReason;

  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class AwsEcsCallResult<T> {
  const AwsEcsCallResult({required this.value, this.result});
  final T value;
  final AwsEcsResult? result;
}

/// Wraps an AWS ECS call in a CLIENT span. [operation] is one of
/// `runTask`, `startTask`, `stopTask`, `describeTasks`, `listTasks`,
/// `registerTaskDefinition`, `deregisterTaskDefinition`,
/// `describeTaskDefinition`, `listTaskDefinitions`,
/// `createService`, `updateService`, `deleteService`,
/// `describeServices`, `listServices`, `updateServicePrimaryTaskSet`,
/// `createTaskSet`, `deleteTaskSet`, `updateTaskSet`, `describeTaskSets`,
/// `createCluster`, `deleteCluster`, `describeClusters`, `listClusters`,
/// `putClusterCapacityProviders`, `executeCommand`, `exec.session.start`,
/// `tagResource`, `untagResource`, `submitTaskStateChange`,
/// `submitContainerStateChange`.
Future<T> tracedAwsEcs<T>({
  required String operation,
  required Future<AwsEcsCallResult<T>> Function() invoke,
}) async {
  if (awsEcsInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'aws_ecs',
    'rpc.method': operation,
    'aws_ecs.operation': operation,
  };

  final span = _tracer().startSpan(
    'aws_ecs $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.region != null) {
        extras.add(OTel.attributeString('aws_ecs.region', res.region!));
      }
      if (res.cluster != null) {
        extras.add(OTel.attributeString('aws_ecs.cluster', res.cluster!));
      }
      if (res.launchType != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.launch_type',
          res.launchType!,
        ));
      }
      if (res.capacityProvider != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.capacity_provider',
          res.capacityProvider!,
        ));
      }
      if (res.taskDefinition != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.task_definition',
          res.taskDefinition!,
        ));
      }
      if (res.taskDefinitionRevision != null) {
        extras.add(OTel.attributeInt(
          'aws_ecs.task_definition.revision',
          res.taskDefinitionRevision!,
        ));
      }
      if (res.taskArn != null) {
        extras.add(OTel.attributeString('aws_ecs.task.arn', res.taskArn!));
      }
      if (res.containerArn != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.container.arn',
          res.containerArn!,
        ));
      }
      if (res.containerName != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.container.name',
          res.containerName!,
        ));
      }
      if (res.image != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.container.image',
          res.image!,
        ));
      }
      if (res.cpuUnits != null) {
        extras.add(OTel.attributeInt('aws_ecs.cpu_units', res.cpuUnits!));
      }
      if (res.memoryMib != null) {
        extras.add(OTel.attributeInt('aws_ecs.memory_mib', res.memoryMib!));
      }
      if (res.gpuCount != null) {
        extras.add(OTel.attributeInt('aws_ecs.gpu_count', res.gpuCount!));
      }
      if (res.runtimePlatform != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.runtime_platform',
          res.runtimePlatform!,
        ));
      }
      if (res.networkMode != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.network_mode',
          res.networkMode!,
        ));
      }
      if (res.serviceName != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.service.name',
          res.serviceName!,
        ));
      }
      if (res.serviceDeploymentId != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.service.deployment_id',
          res.serviceDeploymentId!,
        ));
      }
      if (res.desiredCount != null) {
        extras.add(OTel.attributeInt(
          'aws_ecs.desired_count',
          res.desiredCount!,
        ));
      }
      if (res.runningCount != null) {
        extras.add(OTel.attributeInt(
          'aws_ecs.running_count',
          res.runningCount!,
        ));
      }
      if (res.pendingCount != null) {
        extras.add(OTel.attributeInt(
          'aws_ecs.pending_count',
          res.pendingCount!,
        ));
      }
      if (res.healthStatus != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.health.status',
          res.healthStatus!,
        ));
        if (res.healthStatus == 'UNHEALTHY') {
          span.setStatus(SpanStatusCode.Error, 'ECS task UNHEALTHY');
        }
      }
      if (res.lastStatus != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.task.last_status',
          res.lastStatus!,
        ));
      }
      if (res.stopReason != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.task.stop_reason',
          res.stopReason!,
        ));
        if (res.stopReason == 'OutOfMemoryError' ||
            res.stopReason == 'TaskFailedToStart' ||
            res.stopReason == 'EssentialContainerExited') {
          span.setStatus(
            SpanStatusCode.Error,
            'ECS stop ${res.stopReason}',
          );
        }
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'ECS ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'aws_ecs.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(SpanStatusCode.Error, 'ECS HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
