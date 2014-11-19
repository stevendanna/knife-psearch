# knife-psearch

`knife-psearch` provides access to Chef Server 11's partial search
API.  Partial search sends back a user-specified portion of the
objects returned by a search.  For large searches, this can
dramatically decrease the time knife needs to spend parsing the JSON
response from the server.

# Usage

    knife psearch INDEX QUERY [KEY_MAP] (options)

`knife psearch` supports the same search syntax as `knife search`:

    knife psearch node 'role:webserver'

Use the `-a ATTR` option to select a particular attribute:

    knife psearch node 'role:webserver' -a platform_family

Use the `-i` option to only list the names of the nodes returned by
search:

    knife psearch node 'role:webserver' -i


## Advanced Usage

The optional KEY_MAP argument provides more direct access to the
underlying partial search API.  The partial search API allows the user
to specify a path to a desired key and an alias to return that key as.

For example, if I want to find my apache nodes and show the
`node['apache']['listen_port']`  attribute, I can use a query like:

    knife psearch node 'role:webserver' -a apache.listen_port

However, the KEY_MAP argument allows me to specify an alias for
apache.listen_port:

    knife psearch node 'role:webserver' port=apache.listen_port

which will return the same data but with the shorter name "port" as
the label for apache.listen_port.


# Notes

- When options `-a` and `-i` are not used, searches on the node
  index will automatically construct a partial search that returns the
  same data that is typically displayed by `knife search`.

- When the options `-a` and `-i` are not used, searches on non-node
  indexes will fall back to full search.
