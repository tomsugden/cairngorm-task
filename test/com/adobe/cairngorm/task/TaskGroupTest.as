/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.adobe.cairngorm.task
{

    // TODO consider adding children/removing children from processing taskflow - should it be prevented?


    public class TaskGroupTest extends TaskGroupTestFixture
    {
        private var taskflow:MockTaskGroup = new MockTaskGroup();

        private var nestedTaskflow1:MockTaskGroup = new MockTaskGroup();

        private var nestedTaskflow2:MockTaskGroup = new MockTaskGroup();

        private var nestedChild1:MockTask = new MockTask();

        private var nestedChild2:MockTask = new MockTask();

        private var nestedChild3:MockTask = new MockTask();

        private var nestedChild4:MockTask = new MockTask();

        private var nestedChild5:MockTask = new MockTask();

        private var nestedChild6:MockTask = new MockTask();

        public function TaskGroupTest(methodName:String = null)
        {
            super(methodName);
        }

        override public function setUp():void
        {
            super.setUp();

            // 4 children         
            nestedTaskflow1.addChild(nestedChild1);
            nestedTaskflow1.addChild(nestedChild2);
            nestedTaskflow1.addChild(nestedChild3);
            nestedTaskflow1.addChild(nestedTaskflow2);

            // 3 children
            nestedTaskflow2.addChild(nestedChild4);
            nestedTaskflow2.addChild(nestedChild5);
            nestedTaskflow2.addChild(nestedChild6);
        }

        //-------------------------------
        //  children tests
        //-------------------------------

        public function testChildrenInitiallyEmpty():void
        {
            assertEquals(0, taskflow.children.length);
        }

        public function testAddChildAddsToEndOfChildrenArray():void
        {
            taskflow.addChild(child1);
            taskflow.addChild(child2);

            assertEquals(child2, taskflow.children[1]);
        }

        public function testRemovesChildFromChildrenArray():void
        {
            taskflow.addChild(child1);
            taskflow.addChild(child2);

            taskflow.removeChild(child1);

            assertEquals(1, taskflow.size);
            assertEquals(child2, taskflow.children[0]);
        }

        public function testAddNullChildIgnored():void
        {
            taskflow.addChild(null);

            assertEquals(0, taskflow.size);
        }

        public function testRemoveNullChildIgnored():void
        {
            taskflow.addChild(new MockTask());

            taskflow.removeChild(null);

            assertEquals(1, taskflow.size);

        }

        //-------------------------------
        //  size tests
        //-------------------------------

        public function testSizeInitiallyZero():void
        {
            assertEquals(0, taskflow.size);
        }

        public function testSizeCountsDirectChildren():void
        {
            taskflow.addChild(child1);
            taskflow.addChild(child2);

            assertEquals(2, taskflow.size);
        }

        public function testSizeIncludesNestedChildren():void
        {
            taskflow.addChild(new MockTask());
            taskflow.addChild(nestedTaskflow1); // has 7 nested children
            taskflow.addChild(new MockTask());

            // 3 + 7 = 10
            assertEquals(10, taskflow.size);
        }

        //-------------------------------
        //  progress event tests
        //-------------------------------

        public function testDispatchesProgressEventWhenProcessedChildCompletes():void
        {
            taskflow.addChild(child1);
            taskflow.addChild(child2);

            taskflow.start();

            listenForEvent(taskflow, TaskEvent.TASK_PROGRESS);

            taskflow.processChildNow(child1);
            child1.completeNow();

            assertEvents();
            assertEquals(1, taskEvent.processed);
            assertEquals(2, taskEvent.size);
        }

        public function testDoesNotDispatchProgressEventWhenProcessedChildFaults():void
        {
            taskflow.addChild(child1);
            taskflow.start();

            listenForEvent(taskflow, TaskEvent.TASK_PROGRESS, false);

            taskflow.processChildNow(child1);
            child1.faultNow();

            assertEvents();
        }

        public function testDispatchesProgressEventWhenProcessedChildIsSkipped():void
        {
            child1.enabled = false;
            taskflow.addChild(child1);
            taskflow.start();

            listenForEvent(taskflow, TaskEvent.TASK_PROGRESS);

            taskflow.processChildNow(child1);

            assertEvents();
            assertEquals(1, taskEvent.processed);
            assertEquals(1, taskEvent.size);
        }

        public function testDispatchesProgressEventWhenNestedChildCompletes():void
        {
            taskflow.addChild(nestedTaskflow1);

            listenForEvent(taskflow, TaskEvent.TASK_PROGRESS);

            taskflow.start();
            taskflow.processChildNow(nestedTaskflow1);
            nestedTaskflow1.processChildNow(nestedChild1);
            nestedChild1.completeNow();

            assertEvents();
            assertEquals(1, taskEvent.processed);
            assertEquals(8, taskEvent.size);
        }
    }
}