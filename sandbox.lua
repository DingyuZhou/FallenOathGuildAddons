local addonName, namespace = ...

sandbox = {}

function sandbox.sayHelloWorld()
  print('Fallen Oath: Hello World!')
  message('Fallen Oath: Hello World!')
end

namespace.sandbox = sandbox
