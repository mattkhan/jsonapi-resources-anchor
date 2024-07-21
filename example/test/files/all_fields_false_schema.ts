type Maybe<T> = T | null;

export enum UserRole {
  Admin = "admin",
  ContentCreator = "content_creator",
  External = "external",
  Guest = "guest",
  System = "system",
}

export type Comment = {
  id: number;
  type: "comments";
  created_at: string;
};

export type User = {
  id: number;
  type: "users";
  name: string;
  role: UserRole;
  relationships: {
    comments: Array<Comment>;
    posts: Array<Post>;
  };
};

export type Post = {
  id: number;
  type: "posts";
  description: string;
  relationships: {
    user: User;
    comments: Array<Comment>;
  };
};

export type Exhaustive = {
  id: number;
  type: "exhaustives";
  asserted_string: string;
  asserted_number: number;
  asserted_boolean: boolean;
  asserted_null: null;
  asserted_unknown: unknown;
  asserted_object: {
    a: "a";
    b: 1;
    c: Maybe<string>;
  };
  asserted_maybe_object: Maybe<{
    a: "a";
    b: 1;
    c: Maybe<string>;
  }>;
  asserted_array_record: Array<Record<string, number>>;
  asserted_union: string | number;
  inferred_unknown: unknown;
  uuid: string;
  string: string;
  maybe_string: Maybe<string>;
  text: string;
  integer: number;
  float: number;
  decimal: string;
  datetime: string;
  timestamp: string;
  time: string;
  date: string;
  boolean: boolean;
  array_string: Array<string>;
  maybe_array_string: Maybe<Array<string>>;
  json: Record<string, unknown>;
  jsonb: Record<string, unknown>;
  daterange: unknown;
  enum: unknown;
  virtual_upcased_string: Maybe<string>;
  loljk: never;
};
