# BACKBONE.EXPOSURE
Reduce boilerplate in your backbone models with a slightly opinionated way of doing attributes.

### Creates methods for getting each attribute.

    class Actor extends Exposure.Model
        defaults:
            color: 'blue'
            name: 'tobias'
            age: 34
        jump: -> console.log 'whooo!'

    model1 = new Actor()

    model2 = new Actor
        color: 'yellow'
        name: 'gob'
        age: 35
        tricks: 'illusions'
      
    model1.color() # 'blue'
    model2.tricks() # 'illusions'

### Those same methods also act as setters.

    model1.color 'white'
    model2.name 'el pollo'

    model1.color() # 'white'
    model2.name() # 'el pollo'

### Does the opposite for any normally defined methods! 

    class Actor extends Exposure.Model
        color: -> 'blue'
        name: -> 'tobias'
        age: -> 34

    model1 = new Actor()

    json1 = model1.toJSON()
    json1.color # 'blue'
        
    class DenzelWashington extends Actor
        message: 'Grrr..'
        doIt: (a, b) ->
            @set 'message', "Do it #{a} #{b}!"

    dnzl = new DenzelWashington
        doIt: ['right', 'now']

    dnzl.message() # 'Do it right now!'

## Dependencies (Production)
- backbone.js (http://backbonejs.org)
- underscore.js (http://underscorejs.org)
