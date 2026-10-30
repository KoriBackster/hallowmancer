@abstract class_name monster_response extends RefCounted


#example of a function that every "monster_response" will have and can be reliably called from anywhere...
@abstract func legend()


# another example of how to use an extended class; create a function on the extension, then when an event happens the monster will check if any of its responses has a function that matches the call...
# if not, nothing will happen
