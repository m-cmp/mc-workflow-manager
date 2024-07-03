const MODE_STATE = Object.freeze({
  LIST_MODE: 'LIST_MODE',
  NEW_MODE: 'NEW_MODE',
  EDIT_MODE: 'EDIT_MODE',
  VIEW_MODE: 'VIEW_MODE'
})

const SEGMENT_EDIT_MODE = Object.freeze({
  NEW_MODE: 'new',
  UPDATE_MODE: 'update'
})

const SEGMENT_DIRECTION = Object.freeze({
  FROM: 'from',
  TO: 'to'
})
const SEGMENT_TYPE = Object.freeze({
  JSON: 'application/json',
  XML: 'application/xml',
  TEXT: 'text/plain'
})

const PROTOCOL_TYPE = Object.freeze({
  TCPIP: 'TCP/IP',
  HTTP: 'HTTP',
  HTTPS: 'HTTPS'
})

const PROTOCOL_TYPE_LOWERCASE = Object.freeze({
  TCPIP: 'tcp/ip',
  HTTP: 'http',
  HTTPS: 'https'
})

const MAPPER_PROTOCOL_TYPE = Object.freeze({
  TCPIP: 'TCP/IP',
  HTTPHTTPS: 'HTTP/HTTPS',
})

export {
  MODE_STATE,
  SEGMENT_TYPE,
  PROTOCOL_TYPE,
  SEGMENT_EDIT_MODE,
  SEGMENT_DIRECTION,
  MAPPER_PROTOCOL_TYPE,
  PROTOCOL_TYPE_LOWERCASE
}

