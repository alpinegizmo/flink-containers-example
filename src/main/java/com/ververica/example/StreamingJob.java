/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.ververica.example;

import org.apache.flink.api.common.functions.RichFlatMapFunction;
import org.apache.flink.api.common.restartstrategy.RestartStrategies;
import org.apache.flink.api.common.state.ValueState;
import org.apache.flink.api.common.state.ValueStateDescriptor;
import org.apache.flink.runtime.state.filesystem.FsStateBackend;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.streaming.api.functions.source.RichParallelSourceFunction;
import org.apache.flink.streaming.api.functions.timestamps.BoundedOutOfOrdernessTimestampExtractor;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.util.Collector;

import java.time.Instant;
import java.util.Random;
import java.util.concurrent.TimeUnit;

public class StreamingJob {
	public static void main(String[] args) throws Exception {

		StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

		env.enableCheckpointing(1000);
		env.setRestartStrategy(RestartStrategies.fixedDelayRestart(60, org.apache.flink.api.common.time.Time.of(10, TimeUnit.SECONDS)));

		env.addSource(new ParallelEventSource())
			.assignTimestampsAndWatermarks(new TimestampsAndWatermarks())
			.keyBy(e -> e.userId)
			.flatMap(new CountEventsPerUser())
			.print();

		env.execute();
	}

	private static class Event {
		public final long timestamp;
		public final String userId;

		Event() {
			this.timestamp = Instant.now().toEpochMilli();
			this.userId = "user-" + new Random().nextInt(4);
		}

		@Override
		public String toString() {
			return "Event{" + "user=" + userId + ", @" + timestamp + '}';
		}
	}

	private static class ParallelEventSource extends RichParallelSourceFunction<Event> {
		private volatile boolean running = true;
		private transient long instance;

		@Override
		public void open(Configuration parameters) throws Exception {
			instance = getRuntimeContext().getIndexOfThisSubtask();
		}

		@Override
		public void run(SourceContext<Event> ctx) throws Exception {
			while(running) {
				ctx.collect(new Event());
				Thread.sleep(10);
			}
		}

		@Override
		public void cancel() {
			running = false;
		}
	}

	private static class TimestampsAndWatermarks extends BoundedOutOfOrdernessTimestampExtractor<Event> {
		public TimestampsAndWatermarks() {
			super(Time.milliseconds(2000));
		}

		@Override
		public long extractTimestamp(Event event) {
			return event.timestamp;
		}
	}

	private static class CountEventsPerUser extends RichFlatMapFunction<Event, Tuple2<String, Integer>> {
		private ValueState<Integer> counter;

		@Override
		public void open(Configuration config) {
			counter = getRuntimeContext().getState(new ValueStateDescriptor<>("counter", Integer.class));
		}

		@Override
		public void flatMap(Event event, Collector<Tuple2<String, Integer>> out) throws Exception {
			Integer count = counter.value();

			if (count == null) {
				counter.update(1);
			} else {
				counter.update(++count);

				if (count % 1000 == 0) {
					out.collect(new Tuple2<>(event.userId, count));
				}
			}
		}
	}
}
