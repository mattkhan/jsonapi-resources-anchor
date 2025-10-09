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
  createdAt: string;
  relationships: {};
};

export type User = {
  id: number;
  type: "users";
  role: UserRole;
  relationships: {
    comments: Array<Comment>;
  };
};

export type Post = {
  id: number;
  type: "posts";
  description: string;
  relationships: {
    user: User;
    comments: Array<Comment>;
    participants: Array<User>;
  };
};

export type Exhaustive = {
  id: number;
  type: "exhaustives";
  /** My asserted string. */
  assertedString: string;
  assertedNumber: number;
  assertedBoolean: boolean;
  assertedNull: null;
  assertedUnknown: unknown;
  assertedObject: {
    a: "a";
    "b-dash": 1;
    c: Maybe<string>;
    d_optional?: Maybe<string>;
  };
  assertedMaybeObject: Maybe<{
    a: "a";
    "b-dash": 1;
    c: Maybe<string>;
    d_optional?: Maybe<string>;
  }>;
  assertedArrayRecord: Array<Record<string, number>>;
  assertedUnion: {
    str: string;
    union: Maybe<string> | false | boolean | unknown | number | number | number | Array<number> | ("a") & ("b" | "c") | 2 | "union woo";
    array: Array<Maybe<string>>;
    intersection: ({
      a: 1;
    }) & ({
      b: Maybe<true>;
      s: "string lit";
    });
    next: {
      i: number;
      f?: number;
    };
  } | "union";
  assertedUnionArray: Array<string | number>;
  /** This is a provided description. */
  withDescription: string;
  inferredUnknown: unknown;
  uuid: string;
  string: string;
  maybeString: string;
  text: string;
  integer: number;
  float: number;
  decimal: string;
  datetime: string;
  timestamp: string;
  time: string;
  date: string;
  boolean: boolean;
  arrayString: Array<string>;
  maybeArrayString: Maybe<Array<string>>;
  json: Record<string, unknown>;
  jsonb: Record<string, unknown>;
  daterange: unknown;
  /** This is an enum comment. */
  enum: "sample" | "enum" | "value";
  virtualUpcasedString: Maybe<string>;
  loljk: "never";
  delegatedMaybeString: string;
  modelOverridden: "model_overridden";
  resourceOverridden: "resource_overridden";
  /** This is a comment. */
  withComment: Maybe<string>;
  /** This is a parsed JSON comment. */
  withParsedComment: Maybe<string>;
  defaultedBoolean: boolean;
  defaultedAt: string;
  relationships: {};
  meta: {
    some_count: number;
    extra_stuff: string;
  };
  links: {
    self: string;
    some_url: string;
  };
};
