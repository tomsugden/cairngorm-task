# Cairngorm Task

This is a personal copy of a small open-source library I developed as part of the Cairngorm framework while working for Adobe around 2007-2010. It is long obsolete, but at the time of development provided a clean, declarative approach for bootstrapping Adobe Flex applications. In fact, it was used in several of the larger Flex implementations of this period.

For context, this was a time when web browsers were no where near as capable as today. Even playing a video required a plugin! These limitations created space for so-called "Rich Internet Applications" or RIAs, developed using Adobe Flex that compiled into SWF files that ran inside the Flash Player browser plugin, or on the desktop with Adobe AIR. These RIAs were visually rich and interactive, with fancy graphical effects, realtime streaming data, and other capabilities that would eventually become possible with open web standards.

It's well known that Steve Jobs "killed" Adobe Flash Player by disallowing it on the iPhone, and soon afterwards Adobe would divest and refocus their efforts on the web platform. While he was certainly correct that Flash Player was a battery hog and didn't have a great track-record for security, it shouldn't be forgotten that this platform fostered a great deal of creativity and innovation with a vibrant international community of designers and developers.

Back to Cairngorm. It was originally an MVC framework developed by Iteration2, an Edinburgh-based consultancy that specialized in Rich Internet Applications. The founders, Steven Webster and Alistair McLeod, had written the book on Flex. I joined them shortly after their acquisition by Adobe. Over the years, Cairngorm evolved from a simple MVC framework into a broader collection of libraries and best-practice guidance for building complex applications. 

The Cairngorm Task library was one of my contributions. It provided a way to create reusable tasks for common purposes, such as loading a module or fetching some data, and then composing these tasks into sequences and parallel flows using MXML. The declarative approach was clean and intuitive, and sat neatly alongside the declarative user-interface composition of Flex.

The original documentation follows...

## An Example Cairngorm Task

A task may be used wherever there is a need to coordinate multiple asynchronous tasks, processing them in sequence or parallel. It may be used wherever there is the need to start a process that will later complete or generate a fault. A common example is an application start-up sequence. Perhaps an initial service call takes place to fetch the user profile, followed by a number of subsequent requests to fetch data specific to the user's needs. A number of modules and compiled style-sheets may also be loaded during this start-up sequence.

### Declaring a Task in MXML

Here is this example task declared in MXML with the Cairngorm Task library:

```xml
<task:SequenceTask 
  xmlns:mx="http://www.adobe.com/2006/mxml"
  xmlns:task="com.adobe.cairngorm.task "
  xmlns:example="com.adobe.cairngorm.task.example">
  <example:LoadUserProfile/>
  <task:ParallelTask>
    <example:LoadNews/>
    <example:LoadContacts/>
  </task:ParallelTask>
  <task:ParallelTask>
    <LoadModule url="ModuleA.swf"/>
    <LoadModule url="ModuleB.swf"/>
    <LoadStylesheet url="ModuleAStyles.swf"/>
    <LoadStylesheet url="ModuleBStyles.swf"/>
  </task:ParallelTask>
</task:SequenceTask>
```

When expressed in MXML, a task can be self-documenting. The above example declares a sequence that begins with the `LoadUserProfile` work-item. When the user profile has been fetched, the LoadNews and LoadContacts task-items will begin in parallel. Then when they have both completed, the loading of a number of modules and style-sheets commences. When those have completed the entire task is complete.

A task composition can also be assembled in ActionScript, as shown in the code excerpt below:

``` 
var parallel1:ParallelTask=new ParallelTask();
parallel1.addChild(new LoadNews());
parallel1.addChild(new LoadContacts());

var parallel2:ParallelTask=new ParallelTask();
parallel2.addChild(new LoadModule("ModuleA.swf"));
parallel2.addChild(new LoadModule("ModuleB.swf"));
parallel2.addChild(new LoadStylesheet("ModuleAStyles.swf"));
parallel2.addChild(new LoadStylesheet("ModuleBStyles.swf"));

var task:SequenceTask=new SequenceTask();
task.addChild(new LoadUserProfile());
task.addChild(parallel1);
task.addChild(parallel2);
```

The above code assembles the same task as the first MXML example. It is a little harder to read because the children have to be constructed and added manually in the correct order. MXML is generally preferred for complex task compositions, although some users may consider this to be "programming in XML" and prefer ActionScript.

### Creating and Starting a Task

Once a task has been instantiated, it can be started by calling the `start()` method:

```
task.start();
```

The task will begin processing and continues until it completes successfully or one of the children generates a fault. Both of these outcomes are indicated by events:

```
TaskEvent.TASK_COMPLETE
TaskEvent.TASK_ERROR
```

These events can be handled in MXML using in-line event handlers:

```
<example:StartupTask id="task"
                     taskComplete="doSomething()"
                     taskError="doSomethingElse()"/>
```

Or they can be handled in ActionScript:

```
task.addEventListener(TaskEvent.TASK_COMPLETE, taskCompleteHandler);
task.addEventListener(TaskEvent.TASK_FAULT, taskFaultHandler);
```

### Creating a New Task

The Cairngorm Task library includes a few standard task-items – `ParallelTask` and `SequenceTask` – but in most cases developers need to write their own tasks to perform operations specific to their application. For example, the application start-up task composition above included the LoadUserProfile task.

A new task can be written easily by either implementing the `ITask` interface or extending the Task base class. The latter is the simplest approach, since the base class contains some logic general to all tasks. A concrete class only needs to override the `performTask()` method then later invoke `complete()` or `fault()` when the task has completed or a fault has occurred.

Here's the simples task imaginable:

```
public class HelloWorld extends Task
{
    override protected function performTask():void
    {
        trace("Hello World!");
        complete();
    }
}
```

In reality, tasks are likely to invoke asynchronous service calls or integrate with other systems, like a local SQLite database. Here is a more realistic example:

```
public class LoadUserProfile extends Task
{
    override protected function performTask():void
    {
        var service:HttpService=new HttpService();
        service.url="http://my.domain/userprofile";
        service.addEventListener(ResultEvent.RESULT, onResult);
        service.addEventListener(FaultEvent.FAULT, onFault);
        service.send();
    }

    private function onResult(event:ResultEvent):void
    {
        service.removeEventListener(ResultEvent.RESULT, onResult);
        // do something with result
        complete();
    }

    private function onFault(event:FaultEvent):void
    {
        service.removeEventListener(FaultEvent.FAULT, onFault);
        error(event.fault.message);
    }
}
```

In this case, the `performTask()` method creates a new service instance, attaches a couple of event listeners, then invokes the service. When the result event handler is called, the task completes by calling the `complete()` method; or if a fault occurs instead the `error()` method is called.
