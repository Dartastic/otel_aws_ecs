// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_aws_ecs/otel_aws_ecs.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness =
        await maybeInitializeOtelForTest(serviceName: 'otel_aws_ecs-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('runTask records launch type + cpu/memory', () async {
    await tracedAwsEcs<String>(
      operation: 'runTask',
      invoke: () async => const AwsEcsCallResult(
        value: 'ok',
        result: AwsEcsResult(
          region: 'us-east-1',
          cluster: 'prod',
          launchType: 'FARGATE',
          taskDefinition: 'web',
          taskDefinitionRevision: 42,
          cpuUnits: 1024,
          memoryMib: 2048,
          runtimePlatform: 'LINUX_ARM64',
          networkMode: 'awsvpc',
          lastStatus: 'PROVISIONING',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('aws_ecs runTask')!);
    expect(a['aws_ecs.launch_type'], 'FARGATE');
    expect(a['aws_ecs.cpu_units'], 1024);
    expect(a['aws_ecs.runtime_platform'], 'LINUX_ARM64');
  });

  test('OutOfMemoryError stop reason sets span error', () async {
    await tracedAwsEcs<String>(
      operation: 'describeTasks',
      invoke: () async => const AwsEcsCallResult(
        value: 'ok',
        result: AwsEcsResult(
          lastStatus: 'STOPPED',
          stopReason: 'OutOfMemoryError',
        ),
      ),
    );
    expect(
      spans.findSpanByName('aws_ecs describeTasks')!.status,
      SpanStatusCode.Error,
    );
  });

  test('UNHEALTHY task sets span error', () async {
    await tracedAwsEcs<String>(
      operation: 'describeTasks',
      invoke: () async => const AwsEcsCallResult(
        value: 'ok',
        result: AwsEcsResult(healthStatus: 'UNHEALTHY'),
      ),
    );
    expect(
      spans.findSpanByName('aws_ecs describeTasks')!.status,
      SpanStatusCode.Error,
    );
  });

  test('service describeServices records desired/running/pending', () async {
    await tracedAwsEcs<String>(
      operation: 'describeServices',
      invoke: () async => const AwsEcsCallResult(
        value: 'ok',
        result: AwsEcsResult(
          serviceName: 'web',
          desiredCount: 10,
          runningCount: 9,
          pendingCount: 1,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('aws_ecs describeServices')!);
    expect(a['aws_ecs.desired_count'], 10);
    expect(a['aws_ecs.running_count'], 9);
  });

  test('suppression skips spans', () async {
    await runWithoutAwsEcsInstrumentationAsync(() async {
      await tracedAwsEcs<String>(
        operation: 'listClusters',
        invoke: () async => const AwsEcsCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('aws_ecs '), isEmpty);
  });
}
