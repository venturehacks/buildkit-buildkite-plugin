(
  env.BUILDKITE_PLUGINS // "[]" |
  fromjson |
  map(to_entries) |
  flatten(1) |
  map(select(.key | contains("buildkit-buildkite-plugin")) | .value) |
  first // {}
) as $config |

["buildctl"] |
(if env.BUILDKIT_CA then . += ["--tlscacert \(env.BUILDKIT_CA)"] else . end) |
(if env.BUILDKIT_CERT then . += ["--tlscert \(env.BUILDKIT_CERT)"] else . end) |
(if env.BUILDKIT_KEY then . += ["--tlskey \(env.BUILDKIT_KEY)"] else . end) |
(. += ["build"]) |
(. += ["--progress=\($config.progress // "plain")"]) |
(. += ["--frontend=\($config.frontend // "dockerfile.v0")"]) |
(. += ["--local context=\"\($config.context // ".")\""]) |
(. += ["--local dockerfile=\"\($config.dockerfile // $config.context // ".")\""]) |
(if env.BUILDKIT_MOUNT_SSH_AGENT then . += ["--ssh default=\(env.SSH_AUTH_SOCK)"] else . end) |
(if $config.target then . += ["--opt target=\"\($config.target)\""] else . end) |
(if $config.platform then . += ["--opt platform=\"\($config.platform)\""] else . end) |
(. += ($config.build_args // [] | to_entries | map("--opt build-arg:\(.key)=\"\(.value)\""))) |
(. += ($config.import_cache // [] | map("--import-cache " + (. | to_entries | map("\(.key)=\(.value)") | join(","))))) |
(. += ($config.export_cache // [] | map("--export-cache " + (. | to_entries | map("\(.key)=\(.value)") | join(","))))) |
(. += ($config.output // [] | map("--output " + (. | to_entries | map("\\\"\(.key)=\(.value)\\\"") | join(","))))) |
(. | join(" "))
