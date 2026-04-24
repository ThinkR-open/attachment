# Construct a Remote Branch Reference String

This function constructs a reference string for a remote branch in a
version control system like Git. It returns a formatted string combining
the remote name and a specified branch or reference.

## Usage

``` r
complete_remote_branch(remote, remoteref = "HEAD")
```

## Arguments

- remote:

  A character string representing the name of the remote repository
  (e.g., `"origin"`).

- remoteref:

  A character string representing the branch or reference within the
  remote repository. Default is `"HEAD"`.

## Value

A character string. If `remoteref` is `"HEAD"`, it returns just the
`remote` string. If `remoteref` is not `"HEAD"`, it returns a string in
the format `"remote@remoteref"`.
