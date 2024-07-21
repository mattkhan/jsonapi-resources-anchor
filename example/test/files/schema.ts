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
  text: string;
  createdAt: string;
  updatedAt: string;
  relationships: {
    user: User;
    deletedBy: Maybe<User>;
    commentable: Maybe<User | Post>;
  };
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
  assertedString: string;
  assertedNumber: number;
  assertedBoolean: boolean;
  assertedNull: null;
  assertedUnknown: unknown;
  assertedObject: {
    a: "a";
    "b-dash": 1;
    c: Maybe<string>;
  };
  assertedMaybeObject: Maybe<{
    a: "a";
    "b-dash": 1;
    c: Maybe<string>;
  }>;
  assertedArrayRecord: Array<Record<string, number>>;
  assertedUnion: string | number;
  inferredUnknown: unknown;
  uuid: string;
  string: string;
  maybeString: Maybe<string>;
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
  enum: unknown;
  virtualUpcasedString: Maybe<string>;
  loljk: never;
  delegatedMaybeString: Maybe<string>;
};
