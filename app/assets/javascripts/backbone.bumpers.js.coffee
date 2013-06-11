# Public: Extended version of Backbone's Model class. Added features:
#   "hardened attributes" - model will throw an error if you try to do anything
#                           with attributes that were not specified in the 
#                           `defaults` hash or if you try to change the type of
#                           any such attribute.
#   "automatic accessors" - for each of the model's initial attributes there
#                           is a jQuery-style accessor method with the same
#                           name, which makes mocking models in unit tests
#                           easier and writing and reading the code more
#                           pleasant.
#
# attributes - an (plain) Object of initial attributes
# options - see backbone.js documentation

Backbone.Bumpers or= {}

Backbone.Bumpers.add_attribute_name_bumpers = ->
  # Bind reference to original methods in outer scope.
  _get = @get
  _set = @set

  harden_attributes = (snapshot) =>
    # define new methods
    @get = (attribute_key, other_args...) ->
      unless attribute_key of snapshot
        throw "Attempting to `get` non-existent attribute '#{attribute_key}' on model with hard attributes."
      _get.call this, attribute_key, other_args...
    @set = (first_arg, other_args...) ->
      # set can set multiple attributes at a time
      attributes = null
      _check = (attributes_or_attribute_key) ->
        if _.isObject(attributes_or_attribute_key) 
          attributes = attributes_or_attribute_key
          _check(attribute_key) for attribute_key of attributes_or_attribute_key
        else 
          attribute_value = other_args[0]
          if attributes?
            attribute_value = attributes[attributes_or_attribute_key]

          unless attributes_or_attribute_key of snapshot 
            throw "Attempting to `set` non-existent attribute '#{attributes_or_attribute_key}' on model with hard attributes."

          reference_value = snapshot[attributes_or_attribute_key]
          if reference_value? and reference_value.constructor isnt attribute_value.constructor
            throw "Attempting to change the type of hard attribute '#{attributes_or_attribute_key}'."
      
      _check(first_arg) 
      _set.call this, first_arg, other_args...
  harden_attributes @defaults


  # Create a new outer scope for each attribute containing the corresponding
  # attribute key.
  add_accessor_for = (attribute_key) =>
    # make sure we aren't clobbering/overriding any methods provided by Backbone
    if attribute_key of Backbone.Model.prototype
      throw "Attempting to create an accessor method ('#{attribute_key}') with the same name as an existing method."
    # @constructor is SocialPromote.BaseModel (in this case)
    @constructor::[attribute_key] = (attribute_value, other_args...) ->
      if attribute_value?
       # OPTIMIZE: look for a way to do type checking here without checking if this 
       # is a legal attribute, since we already know that it is.
        @set attribute_key, attribute_value, other_args...
      else
        @get attribute_key, other_args...
  add_accessor_for key for own key of @attributes
