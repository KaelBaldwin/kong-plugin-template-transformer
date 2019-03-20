local template = require 'resty.template'
local wrap_schema_error

local require_succeeded, Errors = pcall(require, 'kong.db.errors')
if (require_succeeded) then
    wrap_schema_error = Errors.schema_violation
else
    Errors = require 'kong.dao.errors'
    wrap_schema_error = Errors.schema
end

function check_template(schema, config, dao, is_updating)
  if config.request_template then
    local status, err = pcall(function ()
      template.precompile(config.request_template)
    end)

    if status ~= true then
      return false, wrap_schema_error(err)
    end

    return status, err
  end

  if config.response_template then
    local status, err = pcall(function ()
      template.precompile(config.response_template)
    end)

    if status ~= true then
      return false, wrap_schema_error(err)
    end

    return status, err
  end

  return true
end

return {
  no_consumer = true,
  fields = {
    request_template = {
      type = "string",
      required = false
    },
    response_template = {
      type = "string",
      required = false
    },
    hidden_fields = {
      type = "array",
      required = false
    }
  },
  self_check = check_template
}
