

window.Exposure =
  getMethodKeys: (object) ->
    keys = for own key of object.__proto__ when key isnt 'constructor'
      key if _.isFunction object.__proto__[key]
    _.compact keys

  createMethodsForAttributes: (attributes = @attributes) ->
    # Create a new outer scope for each attribute containing
    # the corresponding attribute key.
    createMethodFor = (key) =>
      # Make sure we aren't clobbering/overriding any methods
      # provided by Backbone.
      if key of Backbone.Model.prototype
        Throw new Exception """
          Attempting to create an accessor method for key '#{key}'
          with the same name as a statically-defined method.
          """
      @constructor::[key] = (value, options...) ->
        if value?
          @set key, value, options...
        else
          @get key, options...
    createMethodFor key for own key of attributes

  createAttributesForMethods: (attributes = @attributes) ->
    _toJSON = @toJSON
    methodKeys = Exposure.getMethodKeys @
    @toJSON = (args...) =>
      json = _toJSON.apply(this, args)
      for key in methodKeys
        json[key] = @[key]()
      json
    
    for key in methodKeys
      if attributes[key]?
        if _.isArray attributes[key]
          @[key].apply(this, attributes[key])
        else
          @[key](attributes[key])
        delete attributes[key]
    
class Exposure.Model extends Backbone.Model
  constructor: (args...) ->
    super(args...)
    fn.apply this, args for fn in [
        Exposure.createAttributesForMethods
        Exposure.createMethodsForAttributes
    ]


