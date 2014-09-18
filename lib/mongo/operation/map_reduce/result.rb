# Copyright (C) 2009-2014 MongoDB, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Mongo
  module Operation
    class MapReduce

      # Defines custom behaviour of results in an aggregation context.
      #
      # @since 2.0.0
      class Result < Operation::Result

        # The counts field for the map/reduce.
        #
        # @since 2.0.0
        COUNTS = 'counts'.freeze

        # The field name for a result without a cursor.
        #
        # @since 2.0.0
        RESULTS = 'results'.freeze

        # The time the operation took constant.
        #
        # @since 2.0.0
        TIME = 'timeMillis'.freeze

        # Gets the map/reduce counts from the reply.
        #
        # @example Get the counts.
        #   result.counts
        #
        # @return [ Hash ] A hash of the result counts.
        #
        # @since 2.0.0
        def counts
          reply.documents[0][COUNTS]
        end

        # Get the documents from the map/reduce.
        #
        # @example Get the documents.
        #   result.documents
        #
        # @return [ Array<BSON::Document> ] The documents.
        #
        # @since 2.0.0
        def documents
          reply.documents[0][RESULTS]
        end

        # Get the execution time of the map/reduce.
        #
        # @example Get the execution time.
        #   result.time
        #
        # @return [ Integer ] The executiong time in milliseconds.
        #
        # @since 2.0.0
        def time
          reply.documents[0][TIME]
        end
      end
    end
  end
end
